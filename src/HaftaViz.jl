module HaftaViz
using Hafta
using Gadfly
using Formatting

# writemime functions for HFB
function Base.writemime(io, ::MIME"text/html", state::Hafta.HFB.HFBState)
    width,height = 10cm,8cm

    write(io, "<table>")
    write(io, "<tr><th colspan=\"2\" style=\"text-align: center;\">HFBState $(size(state.U))</th></tr>")

    # Table of energies and other values
    E, Ek, Ei, Ep = energy(state)
    Aest = trace(state.rho)
    html = """
    <tr><td colspan="2">
    <table style="width: 100%; border: 1px solid gray;">
    <tr>
        <th>Energy</th>
        <th>Free particles E</th>
        <th>Interaction energy (Γ)</th>
        <th>Pairing energy (Δ)</th>
        <th>Particle number</th>
        <th>Chem.pot.</th>
    </tr>
    <tr>
        <td>{:.5f}</td>
        <td>{:.5f}</td>
        <td>{:.5f}</td>
        <td>{:.5f}</td>
        <td>{:.5f}</td>
        <td>{:.5f}</td>
    </tr>
    </table>
    """
    write(io,format(html, E, Ek, Ei, Ep, Aest, state.lambda))

    # rho and kappa matrices
    rho,kappa = abs(state.rho), abs(state.kappa)
    maxz = max(maximum(rho), maximum(kappa))
    scale = Scale.color_continuous(minvalue=0, maxvalue=maxz)

    write(io, "<tr>")
    write(io, "<td>")
    p = spy(rho, Guide.title("rho matrix"), scale)
    draw(SVG(io,width,height,false), p)
    write(io, "</td>")
    write(io, "<td>")
    p = spy(kappa, Guide.title("kappa matrix"), scale)
    draw(SVG(io,width,height,false), p)
    write(io, "</td>")
    write(io, "</tr>")

    # U and V matrices
    U,V = abs(state.U), abs(state.V)
    maxz = max(maximum(U), maximum(V))
    scale = Scale.color_continuous(minvalue=0, maxvalue=maxz)

    write(io, "<tr>")
    write(io, "<td>")
    p = spy(abs(state.U), Guide.title("U matrix"), scale)
    draw(SVG(io,width,height,false), p)
    write(io, "</td>")
    write(io, "<td>")
    p = spy(abs(state.V), Guide.title("V matrix"), scale)
    draw(SVG(io,width,height,false), p)
    write(io, "</td>")
    write(io, "</tr>")

    # the end
    write(io, "</table>")
end

function Base.writemime(io, ::MIME"text/html", hfbi::Hafta.HFB.HFBIterator)
    width,height = 20cm,6cm

    write(io, "<table>")
    write(io, """
    <tr>
        <th style="text-align: center;">
            HFBIterator ($(length(hfbi)) iterations)
        </th>
    </tr>""")

    write(io, "<tr><td>")
    p = plot(
        x=1:length(hfbi.es), y=hfbi.es,
        Geom.line,# Geom.point,
        Guide.title("Absolute value of energy"),
        Guide.xlabel("Iteration"), Guide.ylabel("E")
    )
    draw(SVG(io,width, height,false), p)
    #write(io, "</td></tr>")
    write(io, "<br /")

    #write(io, "<tr><td>")
    logdiffs = log10(abs(diff(hfbi.es)))
    p = plot(
        x=1:length(logdiffs), y=logdiffs,
        yintercept=[-10, -15], Geom.hline(color="red"),
        Geom.line,# Geom.point,
        Guide.title("Differences of consecutive energies"),
        Guide.xlabel("Iteration"), Guide.ylabel("log10(ΔE)")
    )
    draw(SVG(io,width, height,false), p)
    write(io, "</td></tr>")

    # Output the first and the last state
    if length(hfbi.states) > 1
        write(io, """
        <tr>
        <th style="text-align: center; border-top: 3px solid black;">
        Final state
            </th>
        </tr>""")
        write(io, "<tr><td>")
        writemime(io, "text/html", hfbi.states[end])
        write(io, "</td></tr>")
    end

    if false
        write(io, """
        <tr>
            <th style="text-align: center; border-top: 3px solid black;">
                Initial state
            </th>
        </tr>""")
        write(io, "<tr><td>")
        writemime(io, "text/html", hfbi.states[1])
        write(io, "</td></tr>")
    end

    write(io, "</table>")
end

end
