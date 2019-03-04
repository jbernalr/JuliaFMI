"""
Run tests from fmi-cross-check Git repository.
"""

using Test

thisDir = dirname(Base.source_path())
include("$(dirname(thisDir))/src/FMUSimulator.jl")

if Sys.iswindows()
    fmiCrossCheckDir = string(thisDir, "/fmi-cross-check/fmus/2.0/me/win$(Sys.WORD_SIZE)")
elseif Sys.islinux()
    fmiCrossCheckDir = string(thisDir, "/fmi-cross-check/fmus/2.0/me/linux$(Sys.WORD_SIZE)")
else
    error("OS not supportet for this tests.")
end

# Clone or checkout fmi-cross-check repository
"""
    updateFMICrossTest()

Clone or fetch and pull modelica/fmi-cross-check repository from
https://github.com/modelica/fmi-cross-check.git.
"""
function updateFmiCrossTest()

    if isdir("fmi-cross-check")
        # Update repository
    else
        # Clone repository
        print("Cloning repository modelica/fmi-cross-check. ")
        println("This may take some time.")
    end
end


function runFMICrossTests()

    # Check if repository is up to date
    updateFmiCrossTest()

    @testset "FMI Cross Check" begin
        updateFmiCrossTest()
        if Sys.iswindows()
            @testset "Catia" begin
                testCatiaFMUs()
            end;
        end
    end;
end

"""
Test ModelExchange 2.0 FMUs generated by Catia

Tested versions R2015x and R2016x

# Tests
* modelBooleanNetwork1
* ControlledTemperature
* CoupledClutches
* DFFREG
* MixtureGases
* Rectifier
"""
function testCatiaFMUs()
    for version in ["R2015x", "R2016x"]
        @testset "$version" begin
            @test begin
                modelBooleanNetwork1 = string(fmiCrossCheckDir, "/CATIA/$version/BooleanNetwork1/BooleanNetwork1.fmu")
                main(modelBooleanNetwork1)
            end;

            @test begin
                modelControlledTemperature = string(fmiCrossCheckDir, "/CATIA/$version/ControlledTemperature/ControlledTemperature.fmu")
                main(modelControlledTemperature)
            end;

            @test begin
                modelCoupledClutches = string(fmiCrossCheckDir, "/CATIA/$version/CoupledClutches/CoupledClutches.fmu")
                main(modelCoupledClutches)
            end;

            @test begin
                modelDFFREG = string(fmiCrossCheckDir, "/CATIA/$version/DFFREG/DFFREG.fmu")
                main(modelDFFREG)
            end;

            if version=="R2016x"
                @test begin
                    modelMixtureGases = string(fmiCrossCheckDir, "/CATIA/$version/MixtureGases/MixtureGases.fmu")
                    main(modelMixtureGases)
                end;
            end

            @test begin
                modelRectifier = string(fmiCrossCheckDir, "/CATIA/$version/Rectifier/Rectifier.fmu")
                main(modelRectifier)
            end;
        end;
    end
end
