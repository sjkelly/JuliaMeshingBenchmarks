module MeshingBenchmarks

using FileIO
using NRRD
using Meshing
using MeshIO
using GeometryTypes
using BenchmarkTools

function benchmark()
    here = dirname(@__FILE__)

    ctacardio = load(here*"/../data/CTA-cardio.nrrd")
    q = -100

    # flip sign on nrrd data
    # TODO Meshing should support this
    for i in eachindex(ctacardio.data)
        ctacardio.data[i] = -ctacardio.data[i]
    end

    # convert axis array to sdf
    # Meshing might want to support this format natively
    ctasdf = SignedDistanceField(HyperRectangle(Vec(0,0,0), Vec(10,10,10)),ctacardio.data)
    println("CTA-cardio.nrrd loaded")
    println("CTA-cardio.nrrd Float32 runtime")
    m = @btime HomogenousMesh{Point{3,Float32},Face{3,Int}}($ctasdf, MarchingCubes($q))
    for i in 1:5
        m = @btime HomogenousMesh{Point{3,Float32},Face{3,Int}}($ctasdf, MarchingCubes($q))
    end
    println("CTA-cardio.nrrd Float64 runtime")
    m = @btime HomogenousMesh{Point{3,Float64},Face{3,Int}}($ctasdf, MarchingCubes($q))
    for i in 1:5
        m = @btime HomogenousMesh{Point{3,Float64},Face{3,Int}}($ctasdf, MarchingCubes($q))
    end
    save("ctacardio.ply", m)
end

end # module
