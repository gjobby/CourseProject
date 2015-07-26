library(plyr)


## Read data
features <- read.table("./features.txt", colClasses = c("character"))
activity_labels <- read.table("./activity_labels.txt", col.names = c("ActivityId", "Activity"))
x_train <- read.table("./train/X_train.txt")
y_train <- read.table("./train/Y_train.txt")
subject_train <- read.table("./train/subject_train.txt")
x_test <- read.table("./test/X_test.txt")
y_test <- read.table("./test/y_test.txt")
subject_test <- read.table("./test/subject_test.txt")


## Combine the data to one data set
# Binding sensor data
trainSensorDat <- cbind(cbind(x_train, subject_train), y_train)
testSensorDat <- cbind(cbind(x_test, subject_test), y_test)
sensorData <- rbind(trainSensorDat, testSensorDat)

# Name columns
sensorLabels <- rbind(rbind(features, c(562, "Subject")), c(563, "ActivityId"))[,2]
names(sensorData) <- sensorLabels


## Select only the mean and standard deviation
sensorDataMeanStd <- sensorData[,grepl("mean|std|Subject|ActivityId", names(sensorData))]

## Change to meaningful names
sensorDataMeanStd <- join(sensorDataMeanStd, activity_labels, by = "ActivityId", match = "first")
sensorDataMeanStd <- sensorDataMeanStd[,-1]


### Labels the data set with meaningful names.
names(sensorDataMeanStd) <- gsub('\\(|\\)',"",names(sensorDataMeanStd), perl = TRUE)
names(sensorDataMeanStd) <- make.names(names(sensorDataMeanStd))

## Make clearer names
names(sensorDataMeanStd) <- gsub('Acc',"Acceleration",names(sensorDataMeanStd))
names(sensorDataMeanStd) <- gsub('GyroJerk',"AngularAcceleration",names(sensorDataMeanStd))
names(sensorDataMeanStd) <- gsub('Gyro',"AngularSpeed",names(sensorDataMeanStd))
names(sensorDataMeanStd) <- gsub('Mag',"Magnitude",names(sensorDataMeanStd))
names(sensorDataMeanStd) <- gsub('^t',"TimeDomain.",names(sensorDataMeanStd))
names(sensorDataMeanStd) <- gsub('^f',"FrequencyDomain.",names(sensorDataMeanStd))
names(sensorDataMeanStd) <- gsub('\\.mean',".Mean",names(sensorDataMeanStd))
names(sensorDataMeanStd) <- gsub('\\.std',".StandardDeviation",names(sensorDataMeanStd))
names(sensorDataMeanStd) <- gsub('Freq\\.',"Frequency.",names(sensorDataMeanStd))
names(sensorDataMeanStd) <- gsub('Freq$',"Frequency",names(sensorDataMeanStd))


## Tidy data set
sensorAvgByActSub = ddply(sensorDataMeanStd, c("Subject","Activity"), numcolwise(mean))
write.table(sensorAvgByActSub, file = "sensorAvgByActSub.txt", row.name=FALSE)
