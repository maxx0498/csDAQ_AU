using Gtk
using GtkReactive
using InspectDR
using Reactive
using Colors
using DataFrames    
using Printf
using Dates
using CSV
using FileIO    
using LibSerialPort
using Interpolations
using Statistics
using ImageView
using Images
using TETechTC3625RS232
using IDSpeak

IDSpeak.initialize_camera() 
IDSpeak.open_camera()
IDSpeak.prepare_acquisition()
IDSpeak.alloc_and_announce_buffers()
IDSpeak.start_acquisition(1)
IDSpeak.acquire_image()

IDSpeak.image_preview(IDSpeak.acquire_image())

const currentImage1 = Signal(IDSpeak.acquire_image())

(@isdefined wnd) && destroy(wnd)
gui = GtkBuilder(filename=pwd()*"/gui.glade")  # Load GUI

cvs = gui["Image"]
wnd = gui["mainWindow"]
c = canvas(UserUnit)
push!(cvs, c)

serialPort = get_gtk_property(gui["TESerialPort1"], "text", String)
(@isdefined portTE1) || (portTE1 = TETechTC3625RS232.configure_port(serialPort))
TETechTC3625RS232.turn_power_off(portTE1)
TETechTC3625RS232.write_cool_multiplier(portTE1,1)
TETechTC3625RS232.write_heat_multiplier(portTE1,1)


include("global_variables.jl")        # Reactive Signals and global variables
include("te_io.jl")                   # Thermoelectric Signals (wavefrom)
include("gtk_graphs.jl")              # push graphs to the UI#
include("setup_graphs.jl")            # Initialize graphs 
include("daq_loops.jl")               # Contains DAQ loops               
include("gtk_callbacks.jl")           # Link gui to signals               

Gtk.showall(wnd)                      # Show GUI

# Generate signals
sampleHz = fps(0.5*1.0015272)                # Sample frequency
main_elapsed_time = foldp(+, 0.0, sampleHz)  # Main timer
TE1_elapsed_time = foldp(+, 0.0, sampleHz)   # Time since last state change
TE1setT, TE1reset = TE1_signals()            # Signal for setpoint Temperature

# Instantiate parallel  1 Hz Loops and start 10 Hz loop
function main()
    @async sampleHz_data_file()         # Write data file
    @async sampleHz_generic_loop()      # Generic DAQ 
    @async sampleHz_disp_image()      # Generic DAQ 
end
    
MainLoop = map(_ -> main(), sampleHz)   # Run Master Loop

a = true
@async while a == true
    push!(currentImage1, IDSpeak.acquire_image())
    sleep(0.5)
end  

imgsig = map(currentImage1) do r
	img = IDSpeak.image_preview(currentImage1.value)
    img1 = view(img, 1:973, 1:1297)[:,:]
    GtkReactive.copy!(c, img1)
    img1
end

redraw = draw(c, imgsig) do cnvs, image
end

println("Events: ")
push!(updatePower,true)
sleep(1)
push!(updateBandwidth,true)
sleep(1)
push!(updateIntegral, true) 
sleep(1)
push!(updateDerivative, true) 
sleep(1)
push!(updateThermistor, true) 
sleep(1)
push!(updatePolarity, true) 

# You must wait for Godot if running this from the command line or the script will exit out.
wait(Godot)

IDSpeak.close()