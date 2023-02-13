%let imagePath = /home/data/rom/train-jpg/;

/* Specify the caslib and table name for your image data table */
%let imageCaslibName = casuser;
%let imageTableName = train_images;

%let imageTrainingCaslibName = &imageCaslibName;
%let imageTrainingTableName = &imageTableName.Augmented;

/*** Explore images ***/
proc cas;
    /* Summarize images */
    action image.summarizeImages / 
                table={caslib="&imageCaslibName", name="&imageTableName"};

    /* Label frequencies */
    action simple.freq / 
                table={caslib="&imageCaslibName", name="&imageTableName", 
                       vars="_label_"};   
    run;
quit;


/*** Process images ***/
proc cas;
    /* Resize images to 224x224 */
    action image.processImages / 
                table={caslib="&imageCaslibName", name="&imageTableName"}
                imageFunctions={{functionOptions={functionType='RESIZE', 
                                                  height=224, width=224}}}
                casOut={caslib="&imageCaslibName", name="&imageTableName", 
                        replace=TRUE};

    /* Shuffle images */
    action table.shuffle / 
                table={caslib="&imageCaslibName", name="&imageTableName"}
                casOut={caslib="&imageCaslibName", name="&imageTableName", 
                        replace=TRUE};

    /* Partition images */
    action sampling.stratified / 
                table={caslib="&imageCaslibName", name="&imageTableName", groupby={"_label_"}}, 
                samppct=80, 
				samppct2=20,
                partInd=TRUE 
                output={casOut={caslib="&imageCaslibName", 
                                name="&imageTableName", replace=TRUE}, 
                        copyVars="ALL"};
    run;
quit;

/*** Augment the training data 
proc cas;

    action image.augmentImages / 
                table={caslib="&imageCaslibName", name="&imageTableName", 
                       where="_partind_=1"},
                cropList={{usewholeimage=TRUE,
						   mutations={
									horizontalFlip=TRUE
								}}},
                casOut={caslib="&imageTrainingCaslibName", 
                        name="&imageTrainingTableName", replace=TRUE};


    action simple.freq / 
                table={caslib="&imageTrainingCaslibName", 
                       name="&imageTrainingTableName", vars="_label_"};   
    run;
quit;  ***/