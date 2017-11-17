%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% By Paulo Abelha (p.abelha@abdn.ac.uk) 2017
%
%% Script to run a demo for segmenting a point cloud and filtering the best segmentations by superquadric fitting
%   
% This script has linux commands that may require adapting for Windows
%
% We use CGAL 4.10 - Triangulated Surface Mesh Segmentation: https://doc.cgal.org/latest/Surface_mesh_segmentation/
% If you plan on recompiling the binaries, you need to install CGAL: https://doc.cgal.org/latest/Manual/installation.html
%
% We will be using the main binary: segment_meshes.cpp 
%
% pcl is short for point cloud
% SQ is short for superquadric/superparaboloid
% segms is short for segments

%% define variables
% folders
ROOT_PATH = '~/enzymes/segmentation/CGAL/';
INPUT_PATH = [ROOT_PATH 'data/'];
OUTPUT_PATH = [ROOT_PATH 'data_segmented/'];
DEMO_PCL = 'squeegee_2_3dwh';
% segmentation params
k_beg = '3';
k_step = '2';
k_end = '7';
lambda_beg = '0.2';
lambda_step = '0.1';
lambda_end = '0.8';
%% create input folder and clean output folder
mkdir(INPUT_PATH);
%rmdir(OUTPUT_PATH);
mkdir(OUTPUT_PATH);
%% output the help
system([ROOT_PATH 'segment_meshes --help ']);
%% segment the demo point cloud
segm_call = ['sudo ' ROOT_PATH 'segment_meshes -i ' INPUT_PATH ' -o ' OUTPUT_PATH ' -z ' k_beg ':' k_step ':' k_end ',' lambda_beg ':' lambda_step ':' lambda_end ' -e ply'];
system(segm_call);
%% remove similar segms
output_unique_segms_path = RemoveSimilarSegmInFolder(OUTPUT_PATH);
% filter segmentations
FilterSegmentedPCLSInFolder(output_unique_segms_path);



