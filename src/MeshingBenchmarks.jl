module MeshingBenchmarks

using FileIO
using NRRD
using Meshing
using MeshIO
using GeometryTypes
using BenchmarkTools

function benchmark()
    here = dirname(@__FILE__)

    println(pwd())
    ctacardio = load(here*"/../data/CTA-cardio.nrrd")
    q = 100

    samples = 1

    println("CTA-cardio.nrrd loaded")

    println("CTA-cardio.nrrd MarchingCubes Float32 runtime")
    mc = @btime HomogenousMesh(isosurface($ctacardio, MarchingCubes(iso=$q, insidepositive=true), Point{3,Float32}, Face{3,Int})...)
    for i in 1:samples-1
        @btime HomogenousMesh(isosurface($ctacardio, MarchingCubes(iso=$q, insidepositive=true), Point{3,Float32}, Face{3,Int})...)
    end

    println("CTA-cardio.nrrd MarchingCubes Float64 runtime")
    @btime HomogenousMesh(isosurface($ctacardio, MarchingCubes(iso=$q, insidepositive=true), Point{3,Float64}, Face{3,Int})...)
    for i in 1:samples-1
        @btime HomogenousMesh(isosurface($ctacardio, MarchingCubes(iso=$q, insidepositive=true), Point{3,Float64}, Face{3,Int})...)
    end

    # println("CTA-cardio.nrrd MarchingTetrahedra Float32 runtime")
    # mt = @btime HomogenousMesh{Point{3,Float32},Face{3,Int}}($ctasdf, MarchingTetrahedra($q))
    # for i in 1:samples-1
    #     @btime HomogenousMesh{Point{3,Float32},Face{3,Int}}($ctasdf, MarchingTetrahedra($q))
    # end



    println("Saving files")
    save("ctacardio_mc.ply", mc)
    #save("ctacardio_mt.ply", mt)
end

function brain(samples=1, q=100)

    here = dirname(@__FILE__)

    brain = load(here*"/../Seg3DData/Brain_DataSet/MRI-brain50.nrrd")

    brainsdf = SignedDistanceField(HyperRectangle(Vec(0,0,0), Vec(10,10,10)),brain.data)

    println("Brain.nrrd MarchingCubes Float32 runtime")
    mc_brain = @btime HomogenousMesh{Point{3,Float32},Face{3,Int}}($brainsdf, MarchingCubes(iso=$q, insidepositive=false))
    for i in 1:samples-1
        @btime HomogenousMesh{Point{3,Float32},Face{3,Int}}($brainsdf, MarchingCubes(iso=$q, insidepositive=false))
    end

    save("brian_mc.ply", mc_brain)
end

end # module
