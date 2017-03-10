N_PCS = 1;
N_CORES = 2;
TOT_N_CORES = N_PCS*N_CORES;
RANGE_A2 = 10;
STEP_A2=(RANGE_A2-1)/(TOT_N_CORES-1);

pc_number = 0;
train_data_path = 'C:\Users\Paulo\Dropbox\PhD\System\Enzymes\Gen_Data\';

tic
parfor p=1:N_CORES
    pp=(pc_number*N_CORES)+p;
    %a2 = 1+(pp*STEP_A2);
    for a2 = 1:10
        for a3 = 1:10
            for j=0.1:0.2:2
                for k=0.1:0.2:2
                    for l = -1:0.2:1
                        for m = -1:0.2:1
                            lambdaFinal = [1 a2 a3 j k 0 0 0 l m 0 0 0 0 0];
                            [ myPcl, ~, normals ] = UniformSQSampling3D( lambdaFinal, 0.01, 1, 0 );
                            [myPcl, ixs] = DownsamplePCL(myPcl,1000);
                            normals = normals(ixs,:);
                            SH = CalculateSH(myPcl,normals,size(myPcl,1));
                            dlmwrite(strcat(train_data_path,'test_',int2str(pp),'.txt'),reshape(SH,1,size(SH,1)*size(SH,2)),'-append','newline','pc');
                            dlmwrite(strcat(train_data_path,'labeltest_',int2str(pp),'.txt'),[a2 a3 j k l m],'-append','newline','pc');
                        end
                    end
                end
            end
        end
    end
end
toc
