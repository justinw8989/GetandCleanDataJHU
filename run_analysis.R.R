## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# install package
# if (!require("data.table")) {
#   install.packages("data.table")
# }

# if (!require("reshape2")) {
#   install.packages("reshape2")
# }

# load package
library("data.table")
library("reshape2")

# Load: activity labels
activity.label <- read.table("./data/UCI HAR Dataset/activity_labels.txt")[,2]
activity.label

# Load: data column names
features <- read.table("./data/UCI HAR Dataset/features.txt")[,2]

# Extract only the measurements on the mean and standard deviation for each measurement.
extract.features <- grepl("mean|std", features)

# Load and process X_test & y_test data.
X.test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y.test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")

# load subject_test data
subject.test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

# assign column names to x_test
names(X.test) <- features

# Extract only the measurements on the mean and standard deviation for each measurement.
X.test <- X.test[,extract.features]

# Load activity labels
y.test[,2] <- activity.label[y.test[,1]]

# rename the variables in y_test and subject_test data
names(y.test) <- c("activityID", "activityLabel")
names(subject.test) <- "subject"

# Bind data
test.data <- cbind(as.data.table(subject.test), y.test, X.test)

# Load and process X_train & y_train data.
X.train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y.train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")

# load and process subject_train data
subject.train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

# rename
names(X.train) <- features

# Extract only the measurements on the mean and standard deviation for each measurement.
X.train <- X.train[,extract.features]

# Load activity data
y.train[,2] <- activity.label[y.train[,1]]
names(y.train) <- c("activityID", "activityLabel")
names(subject.train) <- "subject"

# Bind data
train.data <- cbind(as.data.table(subject.train), y.train, X.train)

# Merge test and train data
combined.data <- rbind(test.data, train.data)

# retrieve all the labels of combined dataset except first three
id.labels <- c("subject", "activityID", "activityLabel")
data.labels <- setdiff(colnames(combined.data), id.labels)


melt.data <- melt(combined.data, id = id.labels, measure.vars = data.labels)
head(melt.data)

# Apply mean function to dataset using dcast function
tidy.data <- dcast(melt.data, subject + activityLabel ~ variable, mean)
head(tidy.data)

# export the tidy data
write.table(tidy.data, file = "./data/UCI HAR Dataset/tidyData.txt")
