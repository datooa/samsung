install.packages("dplyr")
install.packages("reshape2")
install.packages("plyr")
library(dplyr)
library(reshape2)
library(plyr)

setwd("~/Desktop/UCI HAR Dataset")

features <- read.table("features.txt")
features <- features$V2
train <- read.table("train/X_train.txt")
test <- read.table("test/X_test.txt")
data.combined <- rbind(train, test)
names(data.combined) <- features

# subject column -- creates train_subject and test_subject and then mergest them
train_subject <- read.table("train/subject_train.txt")
train_subject <- train_subject$V1
test_subject <- read.table("test/subject_test.txt")
test_subject <- test_subject$V1
subject <- c(train_subject, test_subject)

# activities column -- creates train_labels and test_labels and then merges them
activity_labels <- read.table("activity_labels.txt")
activity_labels <- as.character(activity_labels$V2)
train_labels <- read.table("train/y_train.txt")
train_labels <- train_labels$V1
test_labels <- read.table("test/y_test.txt")
test_labels <- test_labels$V1
for (i in 1:6){
    train_labels[which(train_labels == i)] <- activity_labels[i]
    test_labels[which(test_labels == i)] <- activity_labels[i]
}
activity <- c(train_labels, test_labels)

data.combined <- cbind(subject, activity, data.combined)

# naming and eliminating columns
data.combined <- data.combined[!duplicated(names(data.combined))]
data.combined <- select(data.combined, 1:2, matches("(mean|std)\\(.*\\)"))

#create tidy dataset

arranged <- arrange(data.combined, subject, activity)

melted <- melt(data.combined, id.vars = c("subject", "activity"))
long <- ddply(melted, c("subject", "activity", "variable"), summarize, mean = mean(value))

write.table(long, file = "tidy.txt", row.names = FALSE)