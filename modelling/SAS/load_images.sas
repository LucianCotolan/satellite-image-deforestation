/*** Macro variable setup ***/
/* Specify file path to your images (such as the giraffe_dolphin_small example data) */
%let imagePath = /home/data/rom/train-jpg/;

/* Specify the caslib and table name for your image data table */
%let imageCaslibName = casuser;
%let imageTableName = train_images;

/* Specify the caslib and table name for the augmented training image data table */
%let imageTrainingCaslibName = &imageCaslibName;
%let imageTrainingTableName = &imageTableName.Augmented;

/*** CAS setup ***/ 
/* Connect to a CAS server */ 
cas; 
/* Automatically assign librefs */ 
caslib _all_ assign; 


/*** Load and display images ***/ 
/* Create temporary caslib and libref for loading images */ 
caslib loadImagesTempCaslib datasource=(srctype="path") path="&imagePath"
    subdirs notactive;
 
libname _loadtmp cas caslib="loadImagesTempCaslib"; 
libname _tmpcas_ cas caslib="casuser"; 
 
/* Load images */ 
proc cas; 
    session %sysfunc(getlsessref(_loadtmp)); 
    action image.loadImages result=casOutInfo / caslib="loadImagesTempCaslib"  
        recurse=TRUE labelLevels=-1 casOut={caslib="&imageCaslibName",  
        name="&imageTableName", replace=TRUE}; 
 
    /* Randomly select images to display */ 
    nRows=max(casOutInfo.OutputCasTables[1, "Rows"], 1); 
    _sampPct_=min(5/nRows*1000, 100); 
    action sampling.srs / table={caslib="&imageCaslibName",  
        name="&imageTableName"}, sampPct=_sampPct_, display={excludeAll=TRUE},  
        output={casOut={caslib="CASUSER", name="_tempDisplayTable_", replace=TRUE},  
        copyVars={"_path_" , "_label_" , "_id_"}}; 
    run; 
quit; 
 
/* Display images */ 
data _tmpcas_._tempDisplayTable_; 
    set _tmpcas_._tempDisplayTable_ end=eof; 
    _labelID_=cat(_label_, ' (_id_=', _id_, ')'); 
 
    if _n_=1 then 
        do; 
            dcl odsout obj(); 
            obj.layout_gridded(columns: 4); 
        end; 
    obj.region(); 
    obj.format_text(text: _labelID_, just: "c", style_attr: 'font_size=9pt'); 
    obj.image(file: _path_, width: "128", height: "128"); 
 
    if eof then 
        do; 
            obj.layout_end(); 
        end; 
run; 

/* Remove temporary caslib and libref */ 
caslib loadImagesTempCaslib drop; 
libname _loadtmp; 
libname _tmpcas_; 