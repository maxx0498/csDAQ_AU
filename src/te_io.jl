
function TE1_signals()
    function trianglewave(x, T, l, u)
        modx = (mod(x, T) + T / 2)
        l + (u - l) * ifelse(modx < T, 2modx / T - 1, -2modx / T + 3)
    end

    function TE_temp(t)
        setT1 = get_gtk_property(gui["set_temp1"], :value, Float64)
        startT = get_gtk_property(gui["startT1"], :value, Float64)
        stopT = get_gtk_property(gui["stopT1"], :value, Float64)
        duration = get_gtk_property(gui["duration1"], :value, Float64)
        T = (stateTE1.value == :Manual) ? setT1 :
            trianglewave(t, duration * 60, startT, stopT)
        return T
    end

    function te_reset(s)
        push!(TE1_elapsed_time, 0.0)
        TE1setT = map(TE_temp, TE1_elapsed_time)
    end

    TE1setT = map(TE_temp, TE1_elapsed_time)
    TE1reset = map(te_reset, filter(s -> s == :Ramp, stateTE1))
    return TE1setT, TE1reset
end
