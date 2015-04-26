###################################
#Before project work steps
###################################
#load data set
setwd("D:\\nauka\\R\\Course2\\Project");
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "getdata-projectfiles-UCI HAR Dataset.zip")
#unpack file manually

###################################fi
#Project objectives
###################################

###################################
##1. Merges the training and the test sets to create one data set.
###################################
library(data.table)
setwd(file.path(getwd(),"UCI HAR Dataset"))
path<-getwd()

#read features
features <- read.table(file.path(path, "features.txt") )
features <- paste0(features[,1],features[,2])
colNames <- gsub(",","_",gsub("-","_",gsub("[()]", "_", features,),),)

#read activity names
activityNames <- read.table(file.path(path, "activity_labels.txt") )
setnames(activityNames, c("activityNumber", "activityName"))

#train set
tTrainSubjectSet <- data.table(read.table(file.path(path, "train", "subject_train.txt") ))
tTrainLabels <- data.table(read.table(file.path(path, "train", "Y_train.txt")))
tTrainSet <- data.table((read.table(file.path(path, "train", "X_train.txt"))))

#test set
tTestSubjectSet <- data.table(read.table(file.path(path, "test", "subject_test.txt"), ))
tTestLabels <- data.table(read.table(file.path(path, "test", "Y_test.txt")))
tTestSet <- data.table((read.table(file.path(path, "test", "X_test.txt"))))

#merge to train and test
tAllSubject <- rbind(tTrainSubjectSet,tTestSubjectSet)
setnames(tAllSubject, "V1", "subject")
tAllLabels <- rbind(tTrainLabels, tTestLabels)
setnames(tAllLabels,"V1", "activityNumber")
tAllSet <- rbind(tTrainSet, tTestSet)
setnames(tAllSet,colNames)

#merge subject and labels
tSubject <- cbind(tAllSubject, tAllLabels)

#merge subjects, labels and data
data <- cbind(tSubject,tAllSet)




#####################################
##2. Extracts only the measurements on the mean and standard deviation for each measurement. 
#####################################
onlyMeanAndStd <- c(names(data)[1], names(data)[2], colNames[grepl("_mean__|_std__", colNames)])
dataOnlyMeanAndStd <- data[,onlyMeanAndStd, with=FALSE]


#####################################
##3. Uses descriptive activity names to name the activities in the data set
#####################################
datadesc <- merge(data, activityNames, by = "activityNumber", all.x = TRUE)


#####################################
##4. Appropriately labels the data set with descriptive variable names. 
#####################################
names(datadesc)

#####################################
##5. From the data set in step 4, creates a second, independent tidy data set 
#with the average of each variable for each activity and each subject.
#####################################
tidyds <- datadesc[, list(count = .N, mean=sapply(.SD, mean)), by=c("activityName","subject")]
write.table(tidyds, "tidyds.dat", sep = "\t", row.names = FALSE)
