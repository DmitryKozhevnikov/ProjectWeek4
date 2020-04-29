**Contents**  

- [Purpose](#purpose)  
- [Data](#data)  
- [Goals](#goals)  
- [Understanding data](#understanding)  
- [Plan of action](#plan)  
- [R Script](#code)  
     - [Step 1](#1)  
     - [Step 2](#2)  
     - [Step 3](#3)  
     - [Step 4](#4)  
     - [Step 5](#5)  
     - [Step 6A](#6A)  
     - [Step 6B](#6B)  
- [Codebook](#codebook)  

# Purpose <a name="purpose"></a>

The purpose of this project is to demonstrate the ability to
collect, work with, and clean a data set. The goal is to prepare
tidy data that can be used for later analysis. 

# Data <a name="data"></a>

One of the most exciting areas in all of data science right now
is wearable computing - see for example this article . Companies
like Fitbit, Nike, and Jawbone Up are racing to develop the
most advanced algorithms to attract new users. The data linked
to from the course website represent data collected from the
accelerometers from the Samsung Galaxy S smartphone. A full
description is available at the site where the data was obtained:   
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones  

Here are the data for the project:  
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip  

# Goals <a name="goals"></a>

1. Create an R script called run_analysis.R that does the following.
    1. Merges the training and the test sets to create one data set.
    2. Extracts only the measurements on the mean and standard deviation for each measurement. 
    3. Uses descriptive activity names to name the activities in the data set.  
    4. Appropriately labels the data set with descriptive variable names.  
    5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
2. Create a Codebook that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md
3. Include a README.md in the repo with your scripts. This file explains how all of the scripts work and how they are connected.

# Understanding data <a name="understanding"></a>

Of all the files in the data set, following are the ones we are interested in to create a full data set.

- **activity_labels.txt**: Contains a list of activities that are measured in the experiment. There are a total of 6 activities, numbered 1 through 6 with labels for each. Examples: Standing, Walking, etc
- **features.txt**: Contain a list of features or variables that are measured during an activity. There are a total of 561 features. Examples: tBodyAcc-mean()-X, tBodyAcc-energy()-Y, etc. Descriptions of these features are given in features_info.txt

The data is split into test and train data sets. Both have exactly the same variables and formats. Only the number of rows are different. Test has 30% and Train has 70% of the total observations(or rows)
- **subject_test.txt**: List of subjects who participated in the experiment (in the test set). There are upto 30 subjects, each represented by a number from 1 to 30.
- **X_test.txt**: Data collected for each activity and subject across all 561 features. This file has 561 columns, each measuring one feature.
- **y_test.txt**: List of activities for which the above data is collected. Each row represents an activity.
- **subject_train.txt, X_train.txt, y_train.txt**: Similar to the above but applies to the training set.

Following is the directory structure of the files we are interested in:

```
[UCI HAR Dataset]
    |
    |____ activity_labels.txt
    |____ features.txt
    |____ [test]
    |       |
    |       |____ subject_test.txt
    |       |____ X_test.txt
    |       |____ y_test.txt
    |
    |
    |____ [train]
            |
            |____ subject_train.txt
            |____ X_train.txt
            |____ y_train.txt

```

# Plan of action <a name="plan"></a>

The goal is to create one dataset out of all the files above. Following are the steps I performed.

1. Add activity labels to y_test. Output: *test_activities*
2. Identify and extract features that were measurements on mean and standard deviation. Output: *f_MeanStd*
3. Extract specific columns from X_test that only contained the above features. Output: *test_MeanStd*
4. Add subject_test and y_test columns to the above to create test_set. Output: *test_set*
5. Follow the same steps to create train_set. Output: *train_set*
6. Final data sets:
    1. Combine test_set and train_set to form a tidy_dataset. Output: *tidy_dataset*
    2. Create averages_dataset from above. Output: *averages_dataset*
7. Create Codebook.

Here is a diagram of the flow (from left to right)

```
activity_labels ____
                    |____ test_activities ___
y_test______________|        (Step 1)        |
                                             |
features __ Mean,Std ___                     |
            (Step 2)    |___ test_MeanStd ___|____ test_set ___
X_test _________________|      (Step 3)      |     (Step 4)    |
                                             |                 |
subject_test ________________________________|                 |
                                                               |
activity_labels ____                                           |____ tidy_dataset ___ averages_dataset
                    |___ train_activities ___                  |       (Step 6A)          (Step 6B)
y_train_____________|                        |                 |
                                             |                 |
features __ Mean,Std ___                     |                 |
                        |__ train_MeanStd ___|___ train_set ___|
X_train ________________|                    |    (Step 5)
                                             |
subject_train _______________________________|
```

Since we do not have to compute anything more than once, following is a more efficient version of the flow that is used.

**Code flow chart**

```
activity_labels ___________
                  |       |____ test_activities ___
y_test____________|_______|         (1)            |
                  |                                |
features __ Mean,Std _____                         |
              (2) |    |  |___ test_MeanStd _______|____ test_set ____
X_test ___________|____|__|         (3)            |        (4)       |
                  |    |                           |                  |
subject_test _____|____|___________________________|                  |
                  |    |                                              |____ tidy_dataset ___ averages_dataset
y_train __________|____|______ train_activities ___                   |         (6A)               (6B)
                       |                           |                  |
X_train _______________|______ train_MeanStd ______|____ train_set ___|
                                                   |        (5)
subject_train _____________________________________|

```

# R Script <a name="code"></a>

Following is a step-by-step demonstration of how the code works. The code itself is available at [run_analysis.R](run_analysis.R).

Import _tidyverse_ library. Tidyverse will be used to read and manipulate data.


```R
library(tidyverse)
```

    Registered S3 methods overwritten by 'ggplot2':
      method         from 
      [.quosures     rlang
      c.quosures     rlang
      print.quosures rlang
    Registered S3 method overwritten by 'rvest':
      method            from
      read_xml.response xml2
    -- Attaching packages --------------------------------------- tidyverse 1.2.1 --
    v ggplot2 3.1.1       v purrr   0.3.3  
    v tibble  2.1.1       v dplyr   0.8.0.1
    v tidyr   0.8.3       v stringr 1.4.0  
    v readr   1.3.1       v forcats 0.4.0  
    Warning message:
    "package 'purrr' was built under R version 3.6.3"-- Conflicts ------------------------------------------ tidyverse_conflicts() --
    x dplyr::filter() masks stats::filter()
    x dplyr::lag()    masks stats::lag()
    

The data will not be downloaded to the storage to avoid clutter. Instead, the data will be stored in a temporary file called _data_ in the memory. Once data is loaded into tibbles from this file, it will be deleted to reduce memory load.


```R
data<-tempfile()
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",data)
file_structure<-unzip(data,list=T)
```

Check directory structure of the compressed file.


```R
head(file_structure)
```


<table>
<thead><tr><th scope=col>Name</th><th scope=col>Length</th><th scope=col>Date</th></tr></thead>
<tbody>
	<tr><td>UCI HAR Dataset/activity_labels.txt   </td><td>   80                                 </td><td>2012-10-10 15:55:00                   </td></tr>
	<tr><td>UCI HAR Dataset/features.txt          </td><td>15785                                 </td><td>2012-10-11 13:41:00                   </td></tr>
	<tr><td>UCI HAR Dataset/features_info.txt     </td><td> 2809                                 </td><td>2012-10-15 15:44:00                   </td></tr>
	<tr><td>UCI HAR Dataset/README.txt            </td><td> 4453                                 </td><td>2012-12-10 10:38:00                   </td></tr>
	<tr><td>UCI HAR Dataset/test/                 </td><td>    0                                 </td><td>2012-11-29 17:01:00                   </td></tr>
	<tr><td>UCI HAR Dataset/test/Inertial Signals/</td><td>    0                                 </td><td>2012-11-29 17:01:00                   </td></tr>
</tbody>
</table>



Only the file name/path and the row number are required to load data. Other columns can be removed.


```R
file_structure$Num<-1:nrow(file_structure)
file_structure<-file_structure[,c("Num","Name")]
file_structure
```


<table>
<thead><tr><th scope=col>Num</th><th scope=col>Name</th></tr></thead>
<tbody>
	<tr><td> 1                                                          </td><td>UCI HAR Dataset/activity_labels.txt                         </td></tr>
	<tr><td> 2                                                          </td><td>UCI HAR Dataset/features.txt                                </td></tr>
	<tr><td> 3                                                          </td><td>UCI HAR Dataset/features_info.txt                           </td></tr>
	<tr><td> 4                                                          </td><td>UCI HAR Dataset/README.txt                                  </td></tr>
	<tr><td> 5                                                          </td><td>UCI HAR Dataset/test/                                       </td></tr>
	<tr><td> 6                                                          </td><td>UCI HAR Dataset/test/Inertial Signals/                      </td></tr>
	<tr><td> 7                                                          </td><td>UCI HAR Dataset/test/Inertial Signals/body_acc_x_test.txt   </td></tr>
	<tr><td> 8                                                          </td><td>UCI HAR Dataset/test/Inertial Signals/body_acc_y_test.txt   </td></tr>
	<tr><td> 9                                                          </td><td>UCI HAR Dataset/test/Inertial Signals/body_acc_z_test.txt   </td></tr>
	<tr><td>10                                                          </td><td>UCI HAR Dataset/test/Inertial Signals/body_gyro_x_test.txt  </td></tr>
	<tr><td>11                                                          </td><td>UCI HAR Dataset/test/Inertial Signals/body_gyro_y_test.txt  </td></tr>
	<tr><td>12                                                          </td><td>UCI HAR Dataset/test/Inertial Signals/body_gyro_z_test.txt  </td></tr>
	<tr><td>13                                                          </td><td>UCI HAR Dataset/test/Inertial Signals/total_acc_x_test.txt  </td></tr>
	<tr><td>14                                                          </td><td>UCI HAR Dataset/test/Inertial Signals/total_acc_y_test.txt  </td></tr>
	<tr><td>15                                                          </td><td>UCI HAR Dataset/test/Inertial Signals/total_acc_z_test.txt  </td></tr>
	<tr><td>16                                                          </td><td>UCI HAR Dataset/test/subject_test.txt                       </td></tr>
	<tr><td>17                                                          </td><td>UCI HAR Dataset/test/X_test.txt                             </td></tr>
	<tr><td>18                                                          </td><td>UCI HAR Dataset/test/y_test.txt                             </td></tr>
	<tr><td>19                                                          </td><td>UCI HAR Dataset/train/                                      </td></tr>
	<tr><td>20                                                          </td><td>UCI HAR Dataset/train/Inertial Signals/                     </td></tr>
	<tr><td>21                                                          </td><td>UCI HAR Dataset/train/Inertial Signals/body_acc_x_train.txt </td></tr>
	<tr><td>22                                                          </td><td>UCI HAR Dataset/train/Inertial Signals/body_acc_y_train.txt </td></tr>
	<tr><td>23                                                          </td><td>UCI HAR Dataset/train/Inertial Signals/body_acc_z_train.txt </td></tr>
	<tr><td>24                                                          </td><td>UCI HAR Dataset/train/Inertial Signals/body_gyro_x_train.txt</td></tr>
	<tr><td>25                                                          </td><td>UCI HAR Dataset/train/Inertial Signals/body_gyro_y_train.txt</td></tr>
	<tr><td>26                                                          </td><td>UCI HAR Dataset/train/Inertial Signals/body_gyro_z_train.txt</td></tr>
	<tr><td>27                                                          </td><td>UCI HAR Dataset/train/Inertial Signals/total_acc_x_train.txt</td></tr>
	<tr><td>28                                                          </td><td>UCI HAR Dataset/train/Inertial Signals/total_acc_y_train.txt</td></tr>
	<tr><td>29                                                          </td><td>UCI HAR Dataset/train/Inertial Signals/total_acc_z_train.txt</td></tr>
	<tr><td>30                                                          </td><td>UCI HAR Dataset/train/subject_train.txt                     </td></tr>
	<tr><td>31                                                          </td><td>UCI HAR Dataset/train/X_train.txt                           </td></tr>
	<tr><td>32                                                          </td><td>UCI HAR Dataset/train/y_train.txt                           </td></tr>
</tbody>
</table>



## Step 1 <a name="1"></a>

Data is loaded using [read_table2()](https://readr.tidyverse.org/reference/read_table.html) function of the tidyverse package.


```R
activity_labels<-read_table2(unz(data,file_structure[1,2]),col_names=c("ActivityID","ActivityLabel"))
```

    Parsed with column specification:
    cols(
      ActivityID = col_double(),
      ActivityLabel = col_character()
    )
    


```R
print(activity_labels)
```

    # A tibble: 6 x 2
      ActivityID ActivityLabel     
           <dbl> <chr>             
    1          1 WALKING           
    2          2 WALKING_UPSTAIRS  
    3          3 WALKING_DOWNSTAIRS
    4          4 SITTING           
    5          5 STANDING          
    6          6 LAYING            
    

The words in the column _ActivityLabel_ is formatted in capital letters seperated by underscores. They will be converted to CamelCase format.


```R
activity_labels$ActivityLabel<-str_replace_all(str_to_title(str_replace_all(activity_labels$ActivityLabel,"_"," "))," ","")
```


```R
print(activity_labels)
```

    # A tibble: 6 x 2
      ActivityID ActivityLabel    
           <dbl> <chr>            
    1          1 Walking          
    2          2 WalkingUpstairs  
    3          3 WalkingDownstairs
    4          4 Sitting          
    5          5 Standing         
    6          6 Laying           
    

Load y_test data


```R
y_test<-read_table2(unz(data,file_structure[18,2]),col_names=c("ActivityID"))
```

    Parsed with column specification:
    cols(
      ActivityID = col_double()
    )
    


```R
print(y_test)
```

    # A tibble: 2,947 x 1
       ActivityID
            <dbl>
     1          5
     2          5
     3          5
     4          5
     5          5
     6          5
     7          5
     8          5
     9          5
    10          5
    # ... with 2,937 more rows
    


```R
test_activities<-left_join(y_test,activity_labels)
```

    Joining, by = "ActivityID"
    


```R
print(test_activities)
```

    # A tibble: 2,947 x 2
       ActivityID ActivityLabel
            <dbl> <chr>        
     1          5 Standing     
     2          5 Standing     
     3          5 Standing     
     4          5 Standing     
     5          5 Standing     
     6          5 Standing     
     7          5 Standing     
     8          5 Standing     
     9          5 Standing     
    10          5 Standing     
    # ... with 2,937 more rows
    

## Step 2 <a name="2"></a>

Load features data


```R
features<-read_table2(unz(data,file_structure[2,2]),col_names=c("FeatureID","FeatureLabel"))
```

    Parsed with column specification:
    cols(
      FeatureID = col_double(),
      FeatureLabel = col_character()
    )
    


```R
print(features)
```

    # A tibble: 561 x 2
       FeatureID FeatureLabel     
           <dbl> <chr>            
     1         1 tBodyAcc-mean()-X
     2         2 tBodyAcc-mean()-Y
     3         3 tBodyAcc-mean()-Z
     4         4 tBodyAcc-std()-X 
     5         5 tBodyAcc-std()-Y 
     6         6 tBodyAcc-std()-Z 
     7         7 tBodyAcc-mad()-X 
     8         8 tBodyAcc-mad()-Y 
     9         9 tBodyAcc-mad()-Z 
    10        10 tBodyAcc-max()-X 
    # ... with 551 more rows
    

Only the rows containing "mean()" and "std()" need to be selected. Care should be taken not to include rows that contain the word "mean" but are not the measurements of mean. 

For example, we need to select *fBodyBodyGyroMag-mean()* but not *fBodyBodyGyroMag-meanFreq()*

_grepl_(grep logical) will return TRUE whenever the RegEx `*(mean|std)[(][)]*` is satisfied. The rows are then filtered based on that.


```R
f_MeanStd<-filter(features,grepl("*(mean|std)[(][)]*",FeatureLabel))
```


```R
print(f_MeanStd)
```

    # A tibble: 66 x 2
       FeatureID FeatureLabel        
           <dbl> <chr>               
     1         1 tBodyAcc-mean()-X   
     2         2 tBodyAcc-mean()-Y   
     3         3 tBodyAcc-mean()-Z   
     4         4 tBodyAcc-std()-X    
     5         5 tBodyAcc-std()-Y    
     6         6 tBodyAcc-std()-Z    
     7        41 tGravityAcc-mean()-X
     8        42 tGravityAcc-mean()-Y
     9        43 tGravityAcc-mean()-Z
    10        44 tGravityAcc-std()-X 
    # ... with 56 more rows
    

There are 66 rows of features that are measurements of mean and standard deviation. However, the contain special characters that cannot be used as column names in R. 


```R
f_MeanStd$FeatureLabel <- str_replace_all(f_MeanStd$FeatureLabel,"mean[(][)]","Mean") %>% 
                            str_replace_all("std[(][)]","Std") %>% str_replace_all("-","")
```


```R
print(f_MeanStd)
```

    # A tibble: 66 x 2
       FeatureID FeatureLabel    
           <dbl> <chr>           
     1         1 tBodyAccMeanX   
     2         2 tBodyAccMeanY   
     3         3 tBodyAccMeanZ   
     4         4 tBodyAccStdX    
     5         5 tBodyAccStdY    
     6         6 tBodyAccStdZ    
     7        41 tGravityAccMeanX
     8        42 tGravityAccMeanY
     9        43 tGravityAccMeanZ
    10        44 tGravityAccStdX 
    # ... with 56 more rows
    

## Step 3 <a name="3"></a>

As we can see above, we only need 66 columns out of 561 columns available in the x_test.txt file. The entire file could be loaded and unnecessary columns could be removed. However, since R loads all data into memory (RAM), this could create out-of-memory issues if the amount of data is larger than the memory. An efficient way to load data is to read only the required columns. Since the x_test.txt file does not contain any column headers, we need to create a string called *col_types* that we will use to read the required 66 columns.

*col_types* is a string of 561 characters. The position of the letter "d" in the string indicates that the column needs to be read as "double". Rest of the columns represented by underscores are ignored. More info on [col_types](https://www.rdocumentation.org/packages/readr/versions/1.3.1/topics/read_table).


```R
col_types<-rep("_",nrow(features))
for (i in f_MeanStd$FeatureID) col_types[i]<-"d"
col_types<-paste(col_types,collapse="")
print(col_types)
```

    [1] "dddddd__________________________________dddddd__________________________________dddddd__________________________________dddddd__________________________________dddddd__________________________________dd___________dd___________dd___________dd___________dd___________dddddd_________________________________________________________________________dddddd_________________________________________________________________________dddddd_________________________________________________________________________dd___________dd___________dd___________dd__________________"
    

Only the required columns will be read and will be labelled according to *f_MeanStd* from step 2.


```R
test_MeanStd<-read_table(unz(data,file_structure[17,2]),col_types=col_types,col_names=f_MeanStd$FeatureLabel)
```


```R
print(test_MeanStd)
```

    # A tibble: 2,947 x 66
       tBodyAccMeanX tBodyAccMeanY tBodyAccMeanZ tBodyAccStdX tBodyAccStdY
               <dbl>         <dbl>         <dbl>        <dbl>        <dbl>
     1         0.257       -0.0233       -0.0147       -0.938       -0.920
     2         0.286       -0.0132       -0.119        -0.975       -0.967
     3         0.275       -0.0261       -0.118        -0.994       -0.970
     4         0.270       -0.0326       -0.118        -0.995       -0.973
     5         0.275       -0.0278       -0.130        -0.994       -0.967
     6         0.279       -0.0186       -0.114        -0.994       -0.970
     7         0.280       -0.0183       -0.104        -0.996       -0.976
     8         0.275       -0.0250       -0.117        -0.996       -0.982
     9         0.273       -0.0210       -0.114        -0.997       -0.976
    10         0.276       -0.0104       -0.0998       -0.998       -0.987
    # ... with 2,937 more rows, and 61 more variables: tBodyAccStdZ <dbl>,
    #   tGravityAccMeanX <dbl>, tGravityAccMeanY <dbl>, tGravityAccMeanZ <dbl>,
    #   tGravityAccStdX <dbl>, tGravityAccStdY <dbl>, tGravityAccStdZ <dbl>,
    #   tBodyAccJerkMeanX <dbl>, tBodyAccJerkMeanY <dbl>, tBodyAccJerkMeanZ <dbl>,
    #   tBodyAccJerkStdX <dbl>, tBodyAccJerkStdY <dbl>, tBodyAccJerkStdZ <dbl>,
    #   tBodyGyroMeanX <dbl>, tBodyGyroMeanY <dbl>, tBodyGyroMeanZ <dbl>,
    #   tBodyGyroStdX <dbl>, tBodyGyroStdY <dbl>, tBodyGyroStdZ <dbl>,
    #   tBodyGyroJerkMeanX <dbl>, tBodyGyroJerkMeanY <dbl>,
    #   tBodyGyroJerkMeanZ <dbl>, tBodyGyroJerkStdX <dbl>, tBodyGyroJerkStdY <dbl>,
    #   tBodyGyroJerkStdZ <dbl>, tBodyAccMagMean <dbl>, tBodyAccMagStd <dbl>,
    #   tGravityAccMagMean <dbl>, tGravityAccMagStd <dbl>,
    #   tBodyAccJerkMagMean <dbl>, tBodyAccJerkMagStd <dbl>,
    #   tBodyGyroMagMean <dbl>, tBodyGyroMagStd <dbl>, tBodyGyroJerkMagMean <dbl>,
    #   tBodyGyroJerkMagStd <dbl>, fBodyAccMeanX <dbl>, fBodyAccMeanY <dbl>,
    #   fBodyAccMeanZ <dbl>, fBodyAccStdX <dbl>, fBodyAccStdY <dbl>,
    #   fBodyAccStdZ <dbl>, fBodyAccJerkMeanX <dbl>, fBodyAccJerkMeanY <dbl>,
    #   fBodyAccJerkMeanZ <dbl>, fBodyAccJerkStdX <dbl>, fBodyAccJerkStdY <dbl>,
    #   fBodyAccJerkStdZ <dbl>, fBodyGyroMeanX <dbl>, fBodyGyroMeanY <dbl>,
    #   fBodyGyroMeanZ <dbl>, fBodyGyroStdX <dbl>, fBodyGyroStdY <dbl>,
    #   fBodyGyroStdZ <dbl>, fBodyAccMagMean <dbl>, fBodyAccMagStd <dbl>,
    #   fBodyBodyAccJerkMagMean <dbl>, fBodyBodyAccJerkMagStd <dbl>,
    #   fBodyBodyGyroMagMean <dbl>, fBodyBodyGyroMagStd <dbl>,
    #   fBodyBodyGyroJerkMagMean <dbl>, fBodyBodyGyroJerkMagStd <dbl>
    

## Step 4 <a name="4"></a>

Read subject data


```R
subject_test<-read_table2(unz(data,file_structure[16,2]),col_names="SubjectID")
```

    Parsed with column specification:
    cols(
      SubjectID = col_double()
    )
    


```R
print(subject_test)
```

    # A tibble: 2,947 x 1
       SubjectID
           <dbl>
     1         2
     2         2
     3         2
     4         2
     5         2
     6         2
     7         2
     8         2
     9         2
    10         2
    # ... with 2,937 more rows
    

The *test_set* is created by column binding **subjectID** from *subject_test*, **ActivityLabel** from *test_activities* and all columns from *test_MeanStd*.


```R
test_set<-bind_cols(subject_test,select(test_activities,ActivityLabel),test_MeanStd)
```


```R
print(test_set)
```

    # A tibble: 2,947 x 68
       SubjectID ActivityLabel tBodyAccMeanX tBodyAccMeanY tBodyAccMeanZ
           <dbl> <chr>                 <dbl>         <dbl>         <dbl>
     1         2 Standing              0.257       -0.0233       -0.0147
     2         2 Standing              0.286       -0.0132       -0.119 
     3         2 Standing              0.275       -0.0261       -0.118 
     4         2 Standing              0.270       -0.0326       -0.118 
     5         2 Standing              0.275       -0.0278       -0.130 
     6         2 Standing              0.279       -0.0186       -0.114 
     7         2 Standing              0.280       -0.0183       -0.104 
     8         2 Standing              0.275       -0.0250       -0.117 
     9         2 Standing              0.273       -0.0210       -0.114 
    10         2 Standing              0.276       -0.0104       -0.0998
    # ... with 2,937 more rows, and 63 more variables: tBodyAccStdX <dbl>,
    #   tBodyAccStdY <dbl>, tBodyAccStdZ <dbl>, tGravityAccMeanX <dbl>,
    #   tGravityAccMeanY <dbl>, tGravityAccMeanZ <dbl>, tGravityAccStdX <dbl>,
    #   tGravityAccStdY <dbl>, tGravityAccStdZ <dbl>, tBodyAccJerkMeanX <dbl>,
    #   tBodyAccJerkMeanY <dbl>, tBodyAccJerkMeanZ <dbl>, tBodyAccJerkStdX <dbl>,
    #   tBodyAccJerkStdY <dbl>, tBodyAccJerkStdZ <dbl>, tBodyGyroMeanX <dbl>,
    #   tBodyGyroMeanY <dbl>, tBodyGyroMeanZ <dbl>, tBodyGyroStdX <dbl>,
    #   tBodyGyroStdY <dbl>, tBodyGyroStdZ <dbl>, tBodyGyroJerkMeanX <dbl>,
    #   tBodyGyroJerkMeanY <dbl>, tBodyGyroJerkMeanZ <dbl>,
    #   tBodyGyroJerkStdX <dbl>, tBodyGyroJerkStdY <dbl>, tBodyGyroJerkStdZ <dbl>,
    #   tBodyAccMagMean <dbl>, tBodyAccMagStd <dbl>, tGravityAccMagMean <dbl>,
    #   tGravityAccMagStd <dbl>, tBodyAccJerkMagMean <dbl>,
    #   tBodyAccJerkMagStd <dbl>, tBodyGyroMagMean <dbl>, tBodyGyroMagStd <dbl>,
    #   tBodyGyroJerkMagMean <dbl>, tBodyGyroJerkMagStd <dbl>, fBodyAccMeanX <dbl>,
    #   fBodyAccMeanY <dbl>, fBodyAccMeanZ <dbl>, fBodyAccStdX <dbl>,
    #   fBodyAccStdY <dbl>, fBodyAccStdZ <dbl>, fBodyAccJerkMeanX <dbl>,
    #   fBodyAccJerkMeanY <dbl>, fBodyAccJerkMeanZ <dbl>, fBodyAccJerkStdX <dbl>,
    #   fBodyAccJerkStdY <dbl>, fBodyAccJerkStdZ <dbl>, fBodyGyroMeanX <dbl>,
    #   fBodyGyroMeanY <dbl>, fBodyGyroMeanZ <dbl>, fBodyGyroStdX <dbl>,
    #   fBodyGyroStdY <dbl>, fBodyGyroStdZ <dbl>, fBodyAccMagMean <dbl>,
    #   fBodyAccMagStd <dbl>, fBodyBodyAccJerkMagMean <dbl>,
    #   fBodyBodyAccJerkMagStd <dbl>, fBodyBodyGyroMagMean <dbl>,
    #   fBodyBodyGyroMagStd <dbl>, fBodyBodyGyroJerkMagMean <dbl>,
    #   fBodyBodyGyroJerkMagStd <dbl>
    

## Step 5 <a name="5"></a>

Repeat steps 1 to 4 to create *train_set*


```R
y_train<-read_table(unz(data,file_structure[32,2]),col_names=c("ActivityID"))
```

    Parsed with column specification:
    cols(
      ActivityID = col_double()
    )
    


```R
print(y_train)
```

    # A tibble: 7,352 x 1
       ActivityID
            <dbl>
     1          5
     2          5
     3          5
     4          5
     5          5
     6          5
     7          5
     8          5
     9          5
    10          5
    # ... with 7,342 more rows
    


```R
train_activities<-left_join(y_train,activity_labels)
```

    Joining, by = "ActivityID"
    


```R
print(train_activities)
```

    # A tibble: 7,352 x 2
       ActivityID ActivityLabel
            <dbl> <chr>        
     1          5 Standing     
     2          5 Standing     
     3          5 Standing     
     4          5 Standing     
     5          5 Standing     
     6          5 Standing     
     7          5 Standing     
     8          5 Standing     
     9          5 Standing     
    10          5 Standing     
    # ... with 7,342 more rows
    


```R
train_MeanStd<-read_table(unz(data,file_structure[31,2]),col_types=col_types,col_names=f_MeanStd$FeatureLabel)
```


```R
print(train_MeanStd)
```

    # A tibble: 7,352 x 66
       tBodyAccMeanX tBodyAccMeanY tBodyAccMeanZ tBodyAccStdX tBodyAccStdY
               <dbl>         <dbl>         <dbl>        <dbl>        <dbl>
     1         0.289      -0.0203         -0.133       -0.995       -0.983
     2         0.278      -0.0164         -0.124       -0.998       -0.975
     3         0.280      -0.0195         -0.113       -0.995       -0.967
     4         0.279      -0.0262         -0.123       -0.996       -0.983
     5         0.277      -0.0166         -0.115       -0.998       -0.981
     6         0.277      -0.0101         -0.105       -0.997       -0.990
     7         0.279      -0.0196         -0.110       -0.997       -0.967
     8         0.277      -0.0305         -0.125       -0.997       -0.967
     9         0.277      -0.0218         -0.121       -0.997       -0.961
    10         0.281      -0.00996        -0.106       -0.995       -0.973
    # ... with 7,342 more rows, and 61 more variables: tBodyAccStdZ <dbl>,
    #   tGravityAccMeanX <dbl>, tGravityAccMeanY <dbl>, tGravityAccMeanZ <dbl>,
    #   tGravityAccStdX <dbl>, tGravityAccStdY <dbl>, tGravityAccStdZ <dbl>,
    #   tBodyAccJerkMeanX <dbl>, tBodyAccJerkMeanY <dbl>, tBodyAccJerkMeanZ <dbl>,
    #   tBodyAccJerkStdX <dbl>, tBodyAccJerkStdY <dbl>, tBodyAccJerkStdZ <dbl>,
    #   tBodyGyroMeanX <dbl>, tBodyGyroMeanY <dbl>, tBodyGyroMeanZ <dbl>,
    #   tBodyGyroStdX <dbl>, tBodyGyroStdY <dbl>, tBodyGyroStdZ <dbl>,
    #   tBodyGyroJerkMeanX <dbl>, tBodyGyroJerkMeanY <dbl>,
    #   tBodyGyroJerkMeanZ <dbl>, tBodyGyroJerkStdX <dbl>, tBodyGyroJerkStdY <dbl>,
    #   tBodyGyroJerkStdZ <dbl>, tBodyAccMagMean <dbl>, tBodyAccMagStd <dbl>,
    #   tGravityAccMagMean <dbl>, tGravityAccMagStd <dbl>,
    #   tBodyAccJerkMagMean <dbl>, tBodyAccJerkMagStd <dbl>,
    #   tBodyGyroMagMean <dbl>, tBodyGyroMagStd <dbl>, tBodyGyroJerkMagMean <dbl>,
    #   tBodyGyroJerkMagStd <dbl>, fBodyAccMeanX <dbl>, fBodyAccMeanY <dbl>,
    #   fBodyAccMeanZ <dbl>, fBodyAccStdX <dbl>, fBodyAccStdY <dbl>,
    #   fBodyAccStdZ <dbl>, fBodyAccJerkMeanX <dbl>, fBodyAccJerkMeanY <dbl>,
    #   fBodyAccJerkMeanZ <dbl>, fBodyAccJerkStdX <dbl>, fBodyAccJerkStdY <dbl>,
    #   fBodyAccJerkStdZ <dbl>, fBodyGyroMeanX <dbl>, fBodyGyroMeanY <dbl>,
    #   fBodyGyroMeanZ <dbl>, fBodyGyroStdX <dbl>, fBodyGyroStdY <dbl>,
    #   fBodyGyroStdZ <dbl>, fBodyAccMagMean <dbl>, fBodyAccMagStd <dbl>,
    #   fBodyBodyAccJerkMagMean <dbl>, fBodyBodyAccJerkMagStd <dbl>,
    #   fBodyBodyGyroMagMean <dbl>, fBodyBodyGyroMagStd <dbl>,
    #   fBodyBodyGyroJerkMagMean <dbl>, fBodyBodyGyroJerkMagStd <dbl>
    


```R
subject_train<-read_table2(unz(data,file_structure[30,2]),col_names="SubjectID")
```

    Parsed with column specification:
    cols(
      SubjectID = col_double()
    )
    


```R
print(subject_train)
```

    # A tibble: 7,352 x 1
       SubjectID
           <dbl>
     1         1
     2         1
     3         1
     4         1
     5         1
     6         1
     7         1
     8         1
     9         1
    10         1
    # ... with 7,342 more rows
    


```R
train_set<-bind_cols(subject_train,select(train_activities,ActivityLabel),train_MeanStd)
```


```R
print(train_set)
```

    # A tibble: 7,352 x 68
       SubjectID ActivityLabel tBodyAccMeanX tBodyAccMeanY tBodyAccMeanZ
           <dbl> <chr>                 <dbl>         <dbl>         <dbl>
     1         1 Standing              0.289      -0.0203         -0.133
     2         1 Standing              0.278      -0.0164         -0.124
     3         1 Standing              0.280      -0.0195         -0.113
     4         1 Standing              0.279      -0.0262         -0.123
     5         1 Standing              0.277      -0.0166         -0.115
     6         1 Standing              0.277      -0.0101         -0.105
     7         1 Standing              0.279      -0.0196         -0.110
     8         1 Standing              0.277      -0.0305         -0.125
     9         1 Standing              0.277      -0.0218         -0.121
    10         1 Standing              0.281      -0.00996        -0.106
    # ... with 7,342 more rows, and 63 more variables: tBodyAccStdX <dbl>,
    #   tBodyAccStdY <dbl>, tBodyAccStdZ <dbl>, tGravityAccMeanX <dbl>,
    #   tGravityAccMeanY <dbl>, tGravityAccMeanZ <dbl>, tGravityAccStdX <dbl>,
    #   tGravityAccStdY <dbl>, tGravityAccStdZ <dbl>, tBodyAccJerkMeanX <dbl>,
    #   tBodyAccJerkMeanY <dbl>, tBodyAccJerkMeanZ <dbl>, tBodyAccJerkStdX <dbl>,
    #   tBodyAccJerkStdY <dbl>, tBodyAccJerkStdZ <dbl>, tBodyGyroMeanX <dbl>,
    #   tBodyGyroMeanY <dbl>, tBodyGyroMeanZ <dbl>, tBodyGyroStdX <dbl>,
    #   tBodyGyroStdY <dbl>, tBodyGyroStdZ <dbl>, tBodyGyroJerkMeanX <dbl>,
    #   tBodyGyroJerkMeanY <dbl>, tBodyGyroJerkMeanZ <dbl>,
    #   tBodyGyroJerkStdX <dbl>, tBodyGyroJerkStdY <dbl>, tBodyGyroJerkStdZ <dbl>,
    #   tBodyAccMagMean <dbl>, tBodyAccMagStd <dbl>, tGravityAccMagMean <dbl>,
    #   tGravityAccMagStd <dbl>, tBodyAccJerkMagMean <dbl>,
    #   tBodyAccJerkMagStd <dbl>, tBodyGyroMagMean <dbl>, tBodyGyroMagStd <dbl>,
    #   tBodyGyroJerkMagMean <dbl>, tBodyGyroJerkMagStd <dbl>, fBodyAccMeanX <dbl>,
    #   fBodyAccMeanY <dbl>, fBodyAccMeanZ <dbl>, fBodyAccStdX <dbl>,
    #   fBodyAccStdY <dbl>, fBodyAccStdZ <dbl>, fBodyAccJerkMeanX <dbl>,
    #   fBodyAccJerkMeanY <dbl>, fBodyAccJerkMeanZ <dbl>, fBodyAccJerkStdX <dbl>,
    #   fBodyAccJerkStdY <dbl>, fBodyAccJerkStdZ <dbl>, fBodyGyroMeanX <dbl>,
    #   fBodyGyroMeanY <dbl>, fBodyGyroMeanZ <dbl>, fBodyGyroStdX <dbl>,
    #   fBodyGyroStdY <dbl>, fBodyGyroStdZ <dbl>, fBodyAccMagMean <dbl>,
    #   fBodyAccMagStd <dbl>, fBodyBodyAccJerkMagMean <dbl>,
    #   fBodyBodyAccJerkMagStd <dbl>, fBodyBodyGyroMagMean <dbl>,
    #   fBodyBodyGyroMagStd <dbl>, fBodyBodyGyroJerkMagMean <dbl>,
    #   fBodyBodyGyroJerkMagStd <dbl>
    

# Step 6A <a name="6A"></a>

Create *tidy_dataset*.


```R
tidy_dataset<-bind_rows(train_set,test_set)
```


```R
tidy_dataset$SubjectID<-as.factor(tidy_dataset$SubjectID)
tidy_dataset$ActivityLabel<-as.factor(tidy_dataset$ActivityLabel)
```


```R
print(tidy_dataset)
```

    # A tibble: 10,299 x 68
       SubjectID ActivityLabel tBodyAccMeanX tBodyAccMeanY tBodyAccMeanZ
       <fct>     <fct>                 <dbl>         <dbl>         <dbl>
     1 1         Standing              0.289      -0.0203         -0.133
     2 1         Standing              0.278      -0.0164         -0.124
     3 1         Standing              0.280      -0.0195         -0.113
     4 1         Standing              0.279      -0.0262         -0.123
     5 1         Standing              0.277      -0.0166         -0.115
     6 1         Standing              0.277      -0.0101         -0.105
     7 1         Standing              0.279      -0.0196         -0.110
     8 1         Standing              0.277      -0.0305         -0.125
     9 1         Standing              0.277      -0.0218         -0.121
    10 1         Standing              0.281      -0.00996        -0.106
    # ... with 10,289 more rows, and 63 more variables: tBodyAccStdX <dbl>,
    #   tBodyAccStdY <dbl>, tBodyAccStdZ <dbl>, tGravityAccMeanX <dbl>,
    #   tGravityAccMeanY <dbl>, tGravityAccMeanZ <dbl>, tGravityAccStdX <dbl>,
    #   tGravityAccStdY <dbl>, tGravityAccStdZ <dbl>, tBodyAccJerkMeanX <dbl>,
    #   tBodyAccJerkMeanY <dbl>, tBodyAccJerkMeanZ <dbl>, tBodyAccJerkStdX <dbl>,
    #   tBodyAccJerkStdY <dbl>, tBodyAccJerkStdZ <dbl>, tBodyGyroMeanX <dbl>,
    #   tBodyGyroMeanY <dbl>, tBodyGyroMeanZ <dbl>, tBodyGyroStdX <dbl>,
    #   tBodyGyroStdY <dbl>, tBodyGyroStdZ <dbl>, tBodyGyroJerkMeanX <dbl>,
    #   tBodyGyroJerkMeanY <dbl>, tBodyGyroJerkMeanZ <dbl>,
    #   tBodyGyroJerkStdX <dbl>, tBodyGyroJerkStdY <dbl>, tBodyGyroJerkStdZ <dbl>,
    #   tBodyAccMagMean <dbl>, tBodyAccMagStd <dbl>, tGravityAccMagMean <dbl>,
    #   tGravityAccMagStd <dbl>, tBodyAccJerkMagMean <dbl>,
    #   tBodyAccJerkMagStd <dbl>, tBodyGyroMagMean <dbl>, tBodyGyroMagStd <dbl>,
    #   tBodyGyroJerkMagMean <dbl>, tBodyGyroJerkMagStd <dbl>, fBodyAccMeanX <dbl>,
    #   fBodyAccMeanY <dbl>, fBodyAccMeanZ <dbl>, fBodyAccStdX <dbl>,
    #   fBodyAccStdY <dbl>, fBodyAccStdZ <dbl>, fBodyAccJerkMeanX <dbl>,
    #   fBodyAccJerkMeanY <dbl>, fBodyAccJerkMeanZ <dbl>, fBodyAccJerkStdX <dbl>,
    #   fBodyAccJerkStdY <dbl>, fBodyAccJerkStdZ <dbl>, fBodyGyroMeanX <dbl>,
    #   fBodyGyroMeanY <dbl>, fBodyGyroMeanZ <dbl>, fBodyGyroStdX <dbl>,
    #   fBodyGyroStdY <dbl>, fBodyGyroStdZ <dbl>, fBodyAccMagMean <dbl>,
    #   fBodyAccMagStd <dbl>, fBodyBodyAccJerkMagMean <dbl>,
    #   fBodyBodyAccJerkMagStd <dbl>, fBodyBodyGyroMagMean <dbl>,
    #   fBodyBodyGyroMagStd <dbl>, fBodyBodyGyroJerkMagMean <dbl>,
    #   fBodyBodyGyroJerkMagStd <dbl>
    


```R
head(tidy_dataset)
```


<table>
<thead><tr><th scope=col>SubjectID</th><th scope=col>ActivityLabel</th><th scope=col>tBodyAccMeanX</th><th scope=col>tBodyAccMeanY</th><th scope=col>tBodyAccMeanZ</th><th scope=col>tBodyAccStdX</th><th scope=col>tBodyAccStdY</th><th scope=col>tBodyAccStdZ</th><th scope=col>tGravityAccMeanX</th><th scope=col>tGravityAccMeanY</th><th scope=col>...</th><th scope=col>fBodyGyroStdY</th><th scope=col>fBodyGyroStdZ</th><th scope=col>fBodyAccMagMean</th><th scope=col>fBodyAccMagStd</th><th scope=col>fBodyBodyAccJerkMagMean</th><th scope=col>fBodyBodyAccJerkMagStd</th><th scope=col>fBodyBodyGyroMagMean</th><th scope=col>fBodyBodyGyroMagStd</th><th scope=col>fBodyBodyGyroJerkMagMean</th><th scope=col>fBodyBodyGyroJerkMagStd</th></tr></thead>
<tbody>
	<tr><td>1          </td><td>Standing   </td><td>0.2885845  </td><td>-0.02029417</td><td>-0.1329051 </td><td>-0.9952786 </td><td>-0.9831106 </td><td>-0.9135264 </td><td>0.9633961  </td><td>-0.1408397 </td><td>...        </td><td>-0.9738861 </td><td>-0.9940349 </td><td>-0.9521547 </td><td>-0.9561340 </td><td>-0.9937257 </td><td>-0.9937550 </td><td>-0.9801349 </td><td>-0.9613094 </td><td>-0.9919904 </td><td>-0.9906975 </td></tr>
	<tr><td>1          </td><td>Standing   </td><td>0.2784188  </td><td>-0.01641057</td><td>-0.1235202 </td><td>-0.9982453 </td><td>-0.9753002 </td><td>-0.9603220 </td><td>0.9665611  </td><td>-0.1415513 </td><td>...        </td><td>-0.9871681 </td><td>-0.9897847 </td><td>-0.9808566 </td><td>-0.9758658 </td><td>-0.9903355 </td><td>-0.9919603 </td><td>-0.9882956 </td><td>-0.9833219 </td><td>-0.9958539 </td><td>-0.9963995 </td></tr>
	<tr><td>1          </td><td>Standing   </td><td>0.2796531  </td><td>-0.01946716</td><td>-0.1134617 </td><td>-0.9953796 </td><td>-0.9671870 </td><td>-0.9789440 </td><td>0.9668781  </td><td>-0.1420098 </td><td>...        </td><td>-0.9933990 </td><td>-0.9873282 </td><td>-0.9877948 </td><td>-0.9890155 </td><td>-0.9892801 </td><td>-0.9908667 </td><td>-0.9892548 </td><td>-0.9860277 </td><td>-0.9950305 </td><td>-0.9951274 </td></tr>
	<tr><td>1          </td><td>Standing   </td><td>0.2791739  </td><td>-0.02620065</td><td>-0.1232826 </td><td>-0.9960915 </td><td>-0.9834027 </td><td>-0.9906751 </td><td>0.9676152  </td><td>-0.1439765 </td><td>...        </td><td>-0.9916460 </td><td>-0.9886776 </td><td>-0.9875187 </td><td>-0.9867420 </td><td>-0.9927689 </td><td>-0.9916998 </td><td>-0.9894128 </td><td>-0.9878358 </td><td>-0.9952207 </td><td>-0.9952369 </td></tr>
	<tr><td>1          </td><td>Standing   </td><td>0.2766288  </td><td>-0.01656965</td><td>-0.1153619 </td><td>-0.9981386 </td><td>-0.9808173 </td><td>-0.9904816 </td><td>0.9682244  </td><td>-0.1487502 </td><td>...        </td><td>-0.9919558 </td><td>-0.9879443 </td><td>-0.9935909 </td><td>-0.9900635 </td><td>-0.9955228 </td><td>-0.9943890 </td><td>-0.9914330 </td><td>-0.9890594 </td><td>-0.9950928 </td><td>-0.9954648 </td></tr>
	<tr><td>1          </td><td>Standing   </td><td>0.2771988  </td><td>-0.01009785</td><td>-0.1051373 </td><td>-0.9973350 </td><td>-0.9904868 </td><td>-0.9954200 </td><td>0.9679482  </td><td>-0.1482100 </td><td>...        </td><td>-0.9916595 </td><td>-0.9853661 </td><td>-0.9948360 </td><td>-0.9952833 </td><td>-0.9947329 </td><td>-0.9951562 </td><td>-0.9905000 </td><td>-0.9858609 </td><td>-0.9951433 </td><td>-0.9952387 </td></tr>
</tbody>
</table>



Now that we have the full dataset, delete unrequired tibbles and the temporary file we created in the beginning to load data from.


```R
rm(list=ls()[!(ls()=="tidy_dataset")])
ls()
```


'tidy_dataset'


Write file to disk. More info: https://readr.tidyverse.org/reference/write_delim.html


```R
write_csv(tidy_dataset,"tidy_dataset.csv",append=F)
```

## Step 6B <a name="6B"></a>

The *averages_dataset* should contain all 66 features (columns 3 through 68) from the *tidy_dataset* averaged by _SubjectID_ and _ActivityLabel_. There are 6 activities (or *ActivityLabel*s) and each activity is performed by 30 subjects (or *SubjectID*s). So the *averages_dataset* should contain `6 * 30 = 180` rows and `2 + 66 = 68` columns.

Following functions are used:  
**group_by**: to group the tibble by SubjectID and ActivityLabel.  
**summarise_all**: to compute averages of all features by above groups.  
**[rename_if](https://dplyr.tidyverse.org/reference/select_all.html)**: to add a prefix "Avg" to all computed features.  

This can be achieved using one line of code with the help of pipes in dplyr.


```R
averages_dataset<-tidy_dataset %>% group_by(SubjectID,ActivityLabel) %>% summarise_all(mean) %>% 
                    rename_if(is.numeric, function(x) paste0("Avg",x))
```


```R
print(averages_dataset)
```

    # A tibble: 180 x 68
    # Groups:   SubjectID [30]
       SubjectID ActivityLabel AvgtBodyAccMeanX AvgtBodyAccMeanY AvgtBodyAccMeanZ
       <fct>     <fct>                    <dbl>            <dbl>            <dbl>
     1 1         Laying                   0.222         -0.0405           -0.113 
     2 1         Sitting                  0.261         -0.00131          -0.105 
     3 1         Standing                 0.279         -0.0161           -0.111 
     4 1         Walking                  0.277         -0.0174           -0.111 
     5 1         WalkingDowns~            0.289         -0.00992          -0.108 
     6 1         WalkingUpsta~            0.255         -0.0240           -0.0973
     7 2         Laying                   0.281         -0.0182           -0.107 
     8 2         Sitting                  0.277         -0.0157           -0.109 
     9 2         Standing                 0.278         -0.0184           -0.106 
    10 2         Walking                  0.276         -0.0186           -0.106 
    # ... with 170 more rows, and 63 more variables: AvgtBodyAccStdX <dbl>,
    #   AvgtBodyAccStdY <dbl>, AvgtBodyAccStdZ <dbl>, AvgtGravityAccMeanX <dbl>,
    #   AvgtGravityAccMeanY <dbl>, AvgtGravityAccMeanZ <dbl>,
    #   AvgtGravityAccStdX <dbl>, AvgtGravityAccStdY <dbl>,
    #   AvgtGravityAccStdZ <dbl>, AvgtBodyAccJerkMeanX <dbl>,
    #   AvgtBodyAccJerkMeanY <dbl>, AvgtBodyAccJerkMeanZ <dbl>,
    #   AvgtBodyAccJerkStdX <dbl>, AvgtBodyAccJerkStdY <dbl>,
    #   AvgtBodyAccJerkStdZ <dbl>, AvgtBodyGyroMeanX <dbl>,
    #   AvgtBodyGyroMeanY <dbl>, AvgtBodyGyroMeanZ <dbl>, AvgtBodyGyroStdX <dbl>,
    #   AvgtBodyGyroStdY <dbl>, AvgtBodyGyroStdZ <dbl>,
    #   AvgtBodyGyroJerkMeanX <dbl>, AvgtBodyGyroJerkMeanY <dbl>,
    #   AvgtBodyGyroJerkMeanZ <dbl>, AvgtBodyGyroJerkStdX <dbl>,
    #   AvgtBodyGyroJerkStdY <dbl>, AvgtBodyGyroJerkStdZ <dbl>,
    #   AvgtBodyAccMagMean <dbl>, AvgtBodyAccMagStd <dbl>,
    #   AvgtGravityAccMagMean <dbl>, AvgtGravityAccMagStd <dbl>,
    #   AvgtBodyAccJerkMagMean <dbl>, AvgtBodyAccJerkMagStd <dbl>,
    #   AvgtBodyGyroMagMean <dbl>, AvgtBodyGyroMagStd <dbl>,
    #   AvgtBodyGyroJerkMagMean <dbl>, AvgtBodyGyroJerkMagStd <dbl>,
    #   AvgfBodyAccMeanX <dbl>, AvgfBodyAccMeanY <dbl>, AvgfBodyAccMeanZ <dbl>,
    #   AvgfBodyAccStdX <dbl>, AvgfBodyAccStdY <dbl>, AvgfBodyAccStdZ <dbl>,
    #   AvgfBodyAccJerkMeanX <dbl>, AvgfBodyAccJerkMeanY <dbl>,
    #   AvgfBodyAccJerkMeanZ <dbl>, AvgfBodyAccJerkStdX <dbl>,
    #   AvgfBodyAccJerkStdY <dbl>, AvgfBodyAccJerkStdZ <dbl>,
    #   AvgfBodyGyroMeanX <dbl>, AvgfBodyGyroMeanY <dbl>, AvgfBodyGyroMeanZ <dbl>,
    #   AvgfBodyGyroStdX <dbl>, AvgfBodyGyroStdY <dbl>, AvgfBodyGyroStdZ <dbl>,
    #   AvgfBodyAccMagMean <dbl>, AvgfBodyAccMagStd <dbl>,
    #   AvgfBodyBodyAccJerkMagMean <dbl>, AvgfBodyBodyAccJerkMagStd <dbl>,
    #   AvgfBodyBodyGyroMagMean <dbl>, AvgfBodyBodyGyroMagStd <dbl>,
    #   AvgfBodyBodyGyroJerkMagMean <dbl>, AvgfBodyBodyGyroJerkMagStd <dbl>
    

Write file to disk.


```R
write_csv(averages_dataset,"averages_dataset.csv",append=F)
```

# Codebook <a name="codebook"></a>

Load [dataMaid](https://www.rdocumentation.org/packages/dataMaid/versions/1.4.0) library


```R
library(dataMaid)
```

    Warning message:
    "package 'dataMaid' was built under R version 3.6.3"
    Attaching package: 'dataMaid'
    
    The following object is masked from 'package:dplyr':
    
        summarize
    
    

Writing a function to generate "label" and "shortDescription" [attributes](https://sandsynligvis.dk/2018/03/03/generating-codebooks-in-r/) for variables in the data frame.


```R
create_labels<-function(df) {
    df<-as.data.frame(df)
    for (cname in colnames(df)) {
        cnum<-which(colnames(df)==cname)
        # SubjctID
        if (cname=="SubjectID") {
            df$SubjectID<-as_factor(df$SubjectID)
            attr(df[,cnum], "label") <- "Subject ID" 
            attr(df[,cnum], "shortDescription") <- "Participants identifier." 
            next
        }
        # ActivityLabel
        if (cname=="ActivityLabel") {
            attr(df[,cnum], "label") <- "Activity type" 
            attr(df[,cnum], "shortDescription") <- paste("Type of activity performed by subjects and",
                                                           "measured across various features.")
            next
        }
        # Other features
        label<-c()
        desc<-c()
        # first letter(s) - t or Agvt
        if ((substr(cname,1,1)=="t")|(substr(cname,1,4)=="Avgt")) {
            label<-c("time domain measurement of",label)
            desc<-c("Time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz.",
                    "Then they were filtered using a median filter and a 3rd order low pass Butterworth filter",
                    "with a corner frequency of 20 Hz to remove noise.")
        } 
        # first letter(s) - f or Agvf
        if ((substr(cname,1,1)=="f")|(substr(cname,1,4)=="Avgf")) {
            label<-c("frequency domain measurement of",label)
            desc<-c("A Fast Fourier Transform (FFT) was applied to some of these signals",
                    "to produce frequency domain signals.")
        }
        #Body
        if (grepl("Body",cname)) {
            label<-c(label,"body")
            desc<-c(desc,"Another low pass Butterworth filter with a corner frequency of 0.3 Hz.",
                    "is used to separate body signals from gravity.")
            }
        #Gravity
        if (grepl("Gravity",cname)) {
            label<-c(label,"gravity")
            desc<-c(desc,"Another low pass Butterworth filter with a corner frequency of 0.3 Hz.",
                    "is used to separate gravity signals from body.")
            }
        #Acc
        if (grepl("Acc",cname)) label<-c(label,"linear acceleration")
        #Gyro
        if (grepl("Gyro",cname)) label<-c(label,"angular velocity")
        #Jerk
        if (grepl("Jerk",cname)) label<-c(label,"jerk signals")
        #XYZ
        last_char<-substr(cname,nchar(cname),nchar(cname))
        if ((last_char) %in% c("X","Y","Z")) {
            label<-c(label,"in",last_char,"axis")
            desc<-c(desc,"XYZ is used to denote 3-axial signals in the X, Y and Z directions.")
            }
        #Mag
        if (grepl("Mag",cname)) {
            label<-c("magnitide of",label)
            desc<-c(desc,"Magnitude of these three-dimensional signals were calculated using the Euclidean norm.")
        }
        #Mean
        if (grepl("Mean",cname)) label<-c("mean of",label)
        #Std
        if (grepl("Std",cname)) label<-c("standard deviation of",label)
        # first letters Avg
        if (substr(cname,1,3)=="Avg") label<-c("average of",label)
        # Capitalise the first lett letter of the sentence.
        label<-sub("(^)([[:alpha:]])","\\1\\U\\2", paste(label,collapse=" "), perl=TRUE)
        attr(df[,cnum], "label") <- label
        attr(df[,cnum], "shortDescription") <- paste(desc,collapse=" ")
        }    
    df
}
```

Add labels and description attributes to the dataset.


```R
tidy_dataset<-create_labels(tidy_dataset)
```

A quick check if labels and descriptions are added.


```R
str(tidy_dataset[1:3])
```

    'data.frame':	10299 obs. of  3 variables:
     $ SubjectID    : Factor w/ 30 levels "1","2","3","4",..: 1 1 1 1 1 1 1 1 1 1 ...
      ..- attr(*, "label")= chr "Subject ID"
      ..- attr(*, "shortDescription")= chr "Participants identifier."
     $ ActivityLabel: Factor w/ 6 levels "Laying","Sitting",..: 3 3 3 3 3 3 3 3 3 3 ...
      ..- attr(*, "label")= chr "Activity type"
      ..- attr(*, "shortDescription")= chr "Type of activity performed by subjects and measured across various features."
     $ tBodyAccMeanX: num  0.289 0.278 0.28 0.279 0.277 ...
      ..- attr(*, "label")= chr "Mean of time domain measurement of body linear acceleration in X axis"
      ..- attr(*, "shortDescription")= chr "Time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filte"| __truncated__
    

Use [makeCodebook](https://www.rdocumentation.org/packages/dataMaid/versions/1.4.0/topics/makeCodebook) function to create a codebook for the dataset.


```R
# html codebook
makeCodebook(Tidy_Dataset,replace=T,output="html",codebook=T,file="codebook_html.Rmd")
```


```R
# pdf codebook
makeCodebook(Tidy_Dataset,replace=T,output="pdf",codebook=T,file="codebook_pdf.Rmd",render=F,openResult=F)
```

This function also creates a .Rmd (R Markdown) file that can be tweaked to edit the codebook and add additional information.  
#### View the codebook for the tidy dataset  
- **[Codebook in Markdown format](Codebook.md)**
- **[Codebook in PDF format](Codebook.pdf)**
