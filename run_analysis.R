# Get the data
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dir <- "UCI HAR Dataset" 

if (!file.exists("UCI HAR Dataset")){
        temp <- tempfile()
        download.file(url, temp)
        unzip(temp)
        unlink(temp)
}


# Merges training and test
X_train <- read.table(paste0(dir, '/train/X_train.txt'))
X_test <- read.table(paste0(dir,'/test/X_test.txt'))
X <- rbind(X_train, X_test)

subject_train <- read.table(paste0(dir,'/train/subject_train.txt'))
subject_test <- read.table(paste0(dir,'/test/subject_test.txt'))
subject <- rbind(subject_train, subject_test)

Y_train <- read.table(paste0(dir,'/train/y_train.txt'))
Y_test <- read.table(paste0(dir,'/test/y_test.txt'))
Y <- rbind(Y_train, Y_test)


# Extracts measurements on the mean and standard deviation
features <- read.table(paste0(dir,'/features.txt'))
mean_sd <- grep("-mean\\(\\)|-std\\(\\)", features[, 2])
X_mean_sd <- X[, mean_sd]


# Use activity names to name the activities
names(X_mean_sd) <- features[mean_sd, 2]
names(X_mean_sd) <- tolower(names(X_mean_sd)) 
names(X_mean_sd) <- gsub("\\(|\\)", "", names(X_mean_sd))

activities <- read.table(paste0(dir,'/activity_labels.txt'))
activities[, 2] <- tolower(as.character(activities[, 2]))
activities[, 2] <- gsub("_", "", activities[, 2])

Y[, 1] = activities[Y[, 1], 2]
colnames(Y) <- 'activity'
colnames(subject) <- 'subject'

# Labels data set with the activity
if(!file.exists("Result")){
        dir.create('Result')
}
data <- cbind(subject, X_mean_sd, Y)
write.table(data, "./Result/merged.txt", row.names = F)

# Creates a tidy data set with the average of each variable for each activity and each subject. 
average_df <- aggregate(x=data, by=list(activities=data$activity, subj=data$subject), FUN=mean)
average_df <- average_df[, !(colnames(average_df) %in% c("subj", "activity"))]
write.table(average_df, "./Result/TidyData.txt", row.names = F)