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


"""
    runFMICrossTests()

Run and test all fmi-cross-test that are supportet on current system.
"""
function runFMICrossTests()

    # Check if repository is up to date
    updateFmiCrossTest()

    @testset "FMI Cross Check" begin
        updateFmiCrossTest()
        # Windows tests
        if Sys.iswindows()
            @testset "Catia" begin
                testCatiaFMUs()
            end;
            @testset "SystemModeler" begin
                testSystemModelerFMUs()
            end;
            @testset "Test-FMUs" begin
                testTestFMUsFMUs()
            end;

        # Linux tests
        elseif Sys.islinux()
            @testset "JModelica.org" begin
                testJModelicaFMUs()
            end;
            @testset "MapleSim" begin
                testMapleSimFMUs()
            end;
            @testset "SystemModeler" begin
                testSystemModelerFMUs()
            end;
            @testset "SystemModeler" begin
                testSystemModelerFMUs()
            end;
            @testset "Test-FMUs" begin
                testTestFMUsFMUs()
            end;
        end
    end;
end


"""
    testCatiaFMUs()

Test ModelExchange 2.0 FMUs generated by Catia

Tests versions R2015x and R2016x on 32 and 64 bit Windows.

# Tests
* modelBooleanNetwork1
* ControlledTemperature
* CoupledClutches
* DFFREG
* MixtureGases
* Rectifier
"""
function testCatiaFMUs()

    if !Sys.iswindows()
        error("Test only supportet on 32 and 64 bit Windows.")
    end

    toolName = "CATIA"
    versions = ["R2015x", "R2016x"]
    tests = ["modelBooleanNetwork1" "ControlledTemperature" "CoupledClutches" "DFFREG" "" "Rectifier";
             "modelBooleanNetwork1" "ControlledTemperature" "CoupledClutches" "DFFREG" "MixtureGases" "Rectifier"]

    testTool(toolName, versions, tests)
end


"""
    testJModelicaFMUs()

Test ModelExchange 2.0 FMUs generated by JModelica.org.

Tests version 1.15 on 64 bit Linux.

# Tests
* CauerLowPassAnalog
* ControlledTemperature
* CoupledClutches
* PID_Controller
"""
function testJModelicaFMUs()

    if !Sys.islinux() || Sys.WORD_SIZE != 64
        error("Test only supportet on 64 bit Linux.")
    end

    toolName = "Jmodelica.org"
    versions = ["1.15"]
    tests = ["CauerLowPassAnalog" "ControlledTemperature" "CoupledClutches" "PID_Controller"]

    testTool(toolName, versions, tests)
end


"""
    testMapleSimFMUs()

Test ModelExchange 2.0 FMUs generated by MapleSim.

Tests versions 7.01, 2015.1, 2015.2, 2016.1, 2016.2, 2018 on 32 or 64 bit Linux.

# Tests
* ControlledTemperature
* CoupledClutches
* Rectifier
"""
function testMapleSimFMUs()

    if !Sys.islinux()
        error("Test only supportet on 32 and 64 bit Linux.")
    end

    toolName = "MapleSim"
    if Sys.WORD_SIZE == 32
         versions = ["7.01" "2015.1" "2015.2"]
     elseif Sys.WORD_SIZE == 64
         versions = ["7.01" "2015.1" "2015.2" "2016.1" "2016.2" "2018"]
    else
        error("Unknown WORD_SIZE: $WORD_SIZE")
     end

    tests = ["ControlledTemperature" "" "";
             "ControlledTemperature" "CoupledClutches" "Rectifier";
             "ControlledTemperature" "CoupledClutches" "Rectifier";
             "ControlledTemperature" "CoupledClutches" "Rectifier";
             "ControlledTemperature" "CoupledClutches" "Rectifier";
             "ControlledTemperature" "CoupledClutches" "Rectifier"]

    testTool(toolName, versions, tests)
end


"""
    testSystemModelerFMUs()

Test ModelExchange 2.0 FMUs generated by SystemModeler.

Tests version 5.0 on 64 bit Linux or Windows.

# Tests
* ControlledTemperature
* CoupledClutches
"""
function testSystemModelerFMUs()

    if Sys.WORD_SIZE != 64
        error("Test only supportet on 64 bit Linux or Windows.")
    end

    toolName = "SystemModeler"
    versions = ["5.0"]

    tests = ["ControlledTemperature" "CoupledClutches"]

    testTool(toolName, versions, tests)
end


"""
    testTestFMUsFMUs()

Test ModelExchange 2.0 FMUs generated by Test-FMUs.

Tested version 0.0.1 on 64 bit Linux or Windows

# Tests
*
"""
function testTestFMUsFMUs()

    if Sys.WORD_SIZE != 64
        error("Test only supportet on 64 bit Linux or Windows.")
    end

    toolName = "Test-FMUs"
    versions = ["0.0.1"]

    tests = ["BouncingBall" "Dahlquist" "Feedthrough" "Resource" "Stair" "VanDerPol"]

    testTool(toolName, versions, tests)
end


"""
    function testTool(toolName::String, versions::Array{String,1}, tests)

Heler function to test for generic tools, versions and test cases.
"""
function testTool(toolName::String, versions::Array{String,1}, tests)

    for (i,version) in enumerate(versions)
        @testset "$version" begin
            for test in tests[i,:]
                if test != ""
                    @test begin
                        model = string(fmiCrossCheckDir, "/$toolName/$version/$test/$test.fmu")
                        main(model)
                    end;
                end
            end
        end;
    end
end