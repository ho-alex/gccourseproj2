#Assignment: Getting and Cleaning Data Course Project

# The data linked to from the course website represent data collected from the 
# accelerometers from the Samsung Galaxy S smartphone. A full description is available 
# at the site where the data was obtained:
#   
#   http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
# 
# Here are the data for the project:
#   
#   https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# 
# You should create one R script called run_analysis.R that does the following.
# 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the 
#     average of each variable for each activity and each subject.
library(plyr)  
library(data.table)
library(reshape2)

if (!file.exists("data"))
{
  dir.create("data")
}

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dfile <- "./data/mydataset.zip"

download.file(fileUrl, destfile = dfile)
unzip(dfile, files=NULL, exdir="./data/.")

currentwd <- getwd()
setwd(".\\data\\UCI HAR Dataset")

activity_labels <- read.table(".\\activity_labels.txt")[,2]

features <- read.table(".\\features.txt")[,2]

# load the training set
subjtrain <- read.table(".\\train\\subject_train.txt")
ytrain <- read.table(".\\train\\y_train.txt")

xtrain <- cbind(read.table(".\\train\\X_train.txt"),subjtrain,ytrain)

names(xtrain) <- features
names(xtrain)[562:563] <- c("subject","activity")

# load the test set
subjtest <- read.table(".\\test\\subject_test.txt")
ytest <- read.table(".\\test\\y_test.txt")

xtest <- cbind(read.table(".\\test\\X_test.txt"),subjtest,ytest)

names(xtest) <- features
names(xtest)[562:563] <- c("subject","activity")

# 1. Merges the training and the test sets to create one data set.
xmerge <- rbind(xtrain, xtest)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.

# find the columns that correspond with means and std devs
meanrows <- grep("*mean\\(\\)*", features)
stdrows <- grep("*std\\(\\)*", features)
mycolumns <- sort(c(meanrows,stdrows, 562:563))

xmerge <- xmerge[,mycolumns]

# 3. Uses descriptive activity names to name the activities in the data set
xmerge[,69] <- activity_labels[xmerge[,68]]
names(xmerge)[69] <- "activity_label"
#names(xmerge) <- gsub("^t*", "time", names(xmerge))

# 4. Appropriately labels the data set with descriptive variable names.
names(xmerge) <- gsub("^t","time", names(xmerge))
names(xmerge) <- gsub("^f","frequency", names(xmerge))


# 5. From the data set in step 4, creates a second, independent tidy data set with the 
#     average of each variable for each activity and each subject.
setwd(currentwd)
mytidy<-aggregate(. ~subject + activity, xmerge, mean)
mytidy<-mytidy[order(mytidy$subject,mytidy$activity),]
write.table(xmerge, file = "mytidy.txt",row.name=FALSE)