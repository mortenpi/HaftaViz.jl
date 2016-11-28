# The Orthopolys packages is not in the package repo
hafta_installed = false
try
    import Hafta
    println("Hafta.jl is already available.")
    hafta_installed = true
catch end

if ! hafta_installed
    Pkg.clone("https://github.com/mortenpi/Hafta.jl.git")
    Pkg.build("Hafta")
end
