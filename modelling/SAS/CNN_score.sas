%let imagePath = /home/data/rom/test/;

%let imageCaslibName = casuser;
%let imageTableName = test_images;

/* Score */
proc cas;
    action deepLearn.dlScore / 
                table={caslib="&imageCaslibName", name="&imageTableName"} 
                model='CNN_SIMPLE' 
                initWeights={name='CNN_SIMPLE_WEIGHTS'}
                casout={caslib="&imageCaslibName", 
                        name='test_images_SimpleCNN', replace=1}
                copyVars={'_label_', '_id_'};
    run;
quit;

/* Create confusion matrix */
proc cas;
   action simple.crossTab /
                row="_label_",
                col="_DL_PredName_",
                table={caslib="&imageCaslibName", 
                       name='test_images_SimpleCNN'};
    run;
quit;