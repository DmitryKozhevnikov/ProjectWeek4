# Import tidyverse library. Tidyverse will be used to read and manipulate data.
library(tidyverse)

# The data will not be downloaded to the storage to avoid clutter. 
# Instead, the data will be stored in a temporary file called data in the memory. 
# Once data is loaded into tibbles from this file, it will be deleted to reduce memory load.
data<-tempfile()
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",data)
file_structure<-unzip(data,list=T)
# Only the file name/path and the row number are required to load data. Other columns can be removed.
file_structure$Num<-1:nrow(file_structure)
file_structure<-file_structure[,c("Num","Name")]

# Loading activities data
activity_labels<-read_table2(unz(data,file_structure[1,2]),col_names=c("ActivityID","ActivityLabel"))
# The words in the column ActivityLabel is formatted in capital letters seperated by underscores. 
# They will be converted to CamelCase format.
activity_labels$ActivityLabel<-str_replace_all(str_to_title(str_replace_all(activity_labels$ActivityLabel,"_"," "))," ","")

# Load y_test data
y_test<-read_table2(unz(data,file_structure[18,2]),col_names=c("ActivityID"))
# Join
test_activities<-left_join(y_test,activity_labels)

# Load features data
features<-read_table2(unz(data,file_structure[2,2]),col_names=c("FeatureID","FeatureLabel"))

# Only the rows containing "mean()" and "std()" need to be selected. 
# Care should be taken not to include rows that contain the word "mean" but are not the measurements of mean.
# For example, we need to select fBodyBodyGyroMag-mean() but not fBodyBodyGyroMag-meanFreq()
f_MeanStd<-filter(features,grepl("*(mean|std)[(][)]*",FeatureLabel))
# There are 66 rows of features that are measurements of mean and standard deviation. 
# However, the contain special characters that cannot be used as column names in R.
f_MeanStd$FeatureLabel <- str_replace_all(f_MeanStd$FeatureLabel,"mean[(][)]","Mean") %>% 
  str_replace_all("std[(][)]","Std") %>% str_replace_all("-","")

# Since the x_test.txt file does not contain any column headers, we need to create a string called col_types 
# that we will use to read the required 66 columns.
col_types<-rep("_",nrow(features))
for (i in f_MeanStd$FeatureID) col_types[i]<-"d"
col_types<-paste(col_types,collapse="")

# Only the required columns will be read and will be labelled according to f_MeanStd
test_MeanStd<-read_table(unz(data,file_structure[17,2]),col_types=col_types,col_names=f_MeanStd$FeatureLabel)

# Read subject data
subject_test<-read_table2(unz(data,file_structure[16,2]),col_names="SubjectID")

# The test_set is created by column binding subjectID from subject_test, ActivityLabel from test_activities 
# and all columns from test_MeanStd.
test_set<-bind_cols(subject_test,select(test_activities,ActivityLabel),test_MeanStd)

# Repeat all the steps above to create train_set.
y_train<-read_table(unz(data,file_structure[32,2]),col_names=c("ActivityID"))
train_activities<-left_join(y_train,activity_labels)
train_MeanStd<-read_table(unz(data,file_structure[31,2]),col_types=col_types,col_names=f_MeanStd$FeatureLabel)
subject_train<-read_table2(unz(data,file_structure[30,2]),col_names="SubjectID")
train_set<-bind_cols(subject_train,select(train_activities,ActivityLabel),train_MeanStd)

# Create tidy_dataset.
tidy_dataset<-bind_rows(train_set,test_set)
tidy_dataset$SubjectID<-as.factor(tidy_dataset$SubjectID)
tidy_dataset$ActivityLabel<-as.factor(tidy_dataset$ActivityLabel)

#Write tidy_dataset to disk.
write_csv(tidy_dataset,"tidy_dataset.csv",append=F)

# Create averages_dataset.
# The averages_dataset should contain all 66 features (columns 3 through 68) 
# from the tidy_dataset averaged by SubjectID and ActivityLabel.
averages_dataset<-tidy_dataset %>% group_by(SubjectID,ActivityLabel) %>% summarise_all(mean) %>% 
  rename_if(is.numeric, function(x) paste0("Avg",x))

#Write averages_dataset to disk.
write.table(averages_dataset,"averages_dataset.txt",row.name=F)

# Thank you. - Krishnakanth Allika 2020-04-29 21:20 IST