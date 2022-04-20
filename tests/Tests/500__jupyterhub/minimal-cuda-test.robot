*** Settings ***
Documentation    Minimal test for the CUDA image
Resource         ../../Resources/ODS.robot
Resource         ../../Resources/Common.robot
Resource         ../../Resources/Page/ODH/JupyterHub/JupyterHubSpawner.robot
Resource         ../../Resources/Page/ODH/JupyterHub/JupyterLabLauncher.robot
Resource         ../../Resources/Page/ODH/JupyterHub/GPU.resource
Library          JupyterLibrary
Suite Setup      Verify CUDA Image Suite Setup
Suite Teardown   End Web Test
Force Tags       JupyterHub


*** Variables ***
${NOTEBOOK_IMAGE} =         minimal-gpu
${EXPECTED_CUDA_VERSION} =  11.4


*** Test Cases ***
Verify CUDA Image Can Be Spawned With GPU
    [Documentation]    Spawns CUDA image with 1 GPU
    [Tags]  Sanity
    ...     Resources-GPU
    ...     ODS-1141    ODS-346
    Pass Execution    Passing tests, as suite setup ensures that image can be spawned

Verify CUDA Image Includes Expected CUDA Version
    [Documentation]    Checks CUDA version
    [Tags]  Sanity
    ...     Resources-GPU
    ...     ODS-1142
    Verify Installed CUDA Version    ${EXPECTED_CUDA_VERSION}

Verify PyTorch Library Can See GPUs In Minimal CUDA
    [Documentation]    Installs PyTorch and verifies it can see the GPU
    [Tags]  Sanity
    ...     Resources-GPU
    ...     ODS-1144
    Verify Pytorch Can See GPU    install=True

Verify Tensorflow Library Can See GPUs In Minimal CUDA
    [Documentation]    Installs Tensorflow and verifies it can see the GPU
    [Tags]  Sanity
    ...     Resources-GPU
    ...     ODS-1143
    Verify Tensorflow Can See GPU    install=True

Verify Cuda Image Have NVCC Installed
    [Documentation]     Verifies NVCC Version in Minimal CUDA Image
    [Tags]  Sanity
    ...     ODS-483
    ${nvcc_version} =  Run Cell And Get Output    input=!nvcc --version| grep "release"| awk '{print $5}'
    ${nvcc_version} =  Fetch From Left    ${nvcc_version}  ,
    Should Be Equal As Strings    ${nvcc_version}  ${EXPECTED_CUDA_VERSION}


*** Keywords ***
Verify CUDA Image Suite Setup
    [Documentation]    Suite Setup, spawns CUDA img with one GPU attached
    Begin Web Test
    Launch JupyterHub Spawner From Dashboard
    Spawn Notebook With Arguments  image=${NOTEBOOK_IMAGE}  size=Default  gpus=1
