#
#
#

require 'aws-sdk-s3'
require 'aws-sdk-rekognition'
require 'aws-sdk-dynamodb'
require 'optparse'
require 'json'
require 'securerandom'

# load arguments
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: process_image.rb [options]"

  opts.on("-b", "--bucketName BUCKET_NAME", "S3 Bucket Name") { |v| options[:bucket_name] = v }
  opts.on("-i", "--imageName IMAGE_NAME", "Image Name") { |v| options[:image_name] = v }
  opts.on("-d", "--dynamodbTable DYNAMODB_TABLE", "DynamoDB Table") { |v| options[:dynamodb_table] = v}
end.parse!

raise OptionParser::MissingArgument if options[:bucket_name].nil? || options[:image_name].nil? || options[:dynamodb_table].nil?

# move this to configuration / metadata?
Aws.config.update({ region: ENV['AWS_REGION'] })

#
s3 = Aws::S3::Resource.new
bucket = s3.bucket(options[:bucket_name])

if !bucket.exists?
  p "ERROR: Bucket #{options[:bucket_name]} does not exist!"
  exit()
end

#
rekognition = Aws::Rekognition::Client.new
response = rekognition.detect_labels({
  image: {
    s3_object: {
      bucket: options[:bucket_name],
      name: options[:image_name]
    }
  },
  max_labels: 10,
  min_confidence: 70
})

labels = response.labels.collect { |o| { name: o.name, confidence: o.confidence } }

#
ddb = Aws::DynamoDB::Client.new
ddb.put_item({
  table_name: options[:dynamodb_table],
  item: {
    "ID" => SecureRandom.uuid,
    "ImageName" => "#{options[:bucket_name]}/#{options[:image_name]}",
    "Labels" => labels
  }
})
