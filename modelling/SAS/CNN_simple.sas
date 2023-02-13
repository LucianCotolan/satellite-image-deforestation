%let imagePath = /home/data/rom/train-jpg/;

%let imageCaslibName = casuser;
%let imageTableName = train_images;

%let imageTrainingCaslibName = casuser;
%let imageTrainingTableName = train_images;

/* Build model */ 
proc cas; 
    action deepLearn.buildModel /  
               modelTable={name="Simple_CNN", replace=TRUE} type="CNN"; 
    run; 
quit; 
proc cas; 
    action image.summarizeImages result=summary / 
                table={caslib="&imageTrainingCaslibName", 
                       name="&imageTableName"};
    offsetsTraining=summary.Summary[1, {"mean1stChannel","mean2ndChannel", 
                                        "mean3rdChannel"}];
 
    action deepLearn.addLayer / 
                model="Simple_CNN"
                name="data"
                layer={type='input', nchannels=3, width=224, height=224, offsets=offsetsTraining};

    action deepLearn.addLayer / 
                model="Simple_CNN"
                name="conv1"
                layer={type='convo', act="relu", nFilters=20, width=20, height=20, 
                       stride=1, init='xavier'}
                srcLayers={'data'}; 

    action deepLearn.addLayer /  
                model="Simple_CNN"  
                name="pool1" 
                layer={type='pool', pool='max', width=12, height=12, stride=2} 
                srcLayers={'conv1'}; 

    action deepLearn.addLayer / 
                model="Simple_CNN"
                name="fc1"
                layer={type='fc', n=36, init='xavier', 
                       includeBias='true'}
                srcLayers={'pool1'};

    action deepLearn.addLayer /  
                model="Simple_CNN" 
                name="output" 
                layer={type='output', n=2, act='softmax'}  
                srcLayers={'fc1'}; 
    run; 
quit; 

/* Train model */ 
proc cas; 
    action deepLearn.dlTrain /  
                table={caslib="&imageTrainingCaslibName",  
					   name="&imageTrainingTableName", where="_PartInd_=1"}  
                model='Simple_CNN'  
                modelWeights={name='Simple_CNN_weights',  
                              replace=1} 
                inputs='_image_'  
                target='_label_' nominal='_label_' 
                optimizer={minibatchsize=4,  
                           algorithm={method='ADAM',
						           	  learningrate=0.0001,
									  learningratepolicy='MULTISTEP'}, 
                           maxepochs=5, 
                           loglevel=3}  
                seed=12345; 
    run; 
quit;  

/* Score */
proc cas;
    action deepLearn.dlScore / 
                table={caslib="&imageCaslibName", name="&imageTableName", 
                       where="_PartInd_=2"} 
                model='Simple_CNN' 
                initWeights={name='Simple_CNN_weights'}
                casout={caslib="&imageTrainingCaslibName", 
                        name='imagesScoredSimpleCNN', replace=1}
                copyVars={'_label_', '_id_'};
    run;
quit;

/* Create confusion matrix */
proc cas;
   action simple.crossTab /
                row="_label_",
                col="_DL_PredName_",
                table={caslib="&imageTrainingCaslibName", 
                       name='imagesScoredSimpleCNN'};
    run;
quit;