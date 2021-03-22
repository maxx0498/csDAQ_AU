using PackageCompiler

create_sysimage([:CSV, :Colors, :DataFrames, :Dates, :FileIO, :Gtk, :ImageMagick, :ImageView, :Images, :InspectDR, :Interpolations, :LibSerialPort, :NumericIO, :Printf, :Reactive, :Statistics, :TETechTC3625RS232], sysimage_path="sys_daq.so", precompile_execution_file="main.jl")'
