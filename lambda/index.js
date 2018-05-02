/**
 * [description]
 * 
 */

const Batch = require('aws-sdk/clients/batch')
const uuid = require('uuid/v4')
const util = require('util')

const JOB_DEFINITION = process.env.JOB_DEFINITION
const JOB_QUEUE = process.env.JOB_QUEUE

const IMAGES_BUCKET = process.env.IMAGES_BUCKET
const IMAGES_TABLE = process.env.IMAGES_TABLE

const client = new Batch()

exports.handler = async (event) => {
  console.log(util.inspect(event, { depth: 5 }))

  let result = {}

  try {
    let params = {
      jobDefinition: JOB_DEFINITION,
      jobName: uuid(),
      jobQueue: JOB_QUEUE,
      parameters: {
        bucketName: IMAGES_BUCKET,
        imageName: event.imageName,
        dynamoTable: IMAGES_BUCKET
      }
    }

    result = await client.submitJob(params).promise()
    console.log(`Started AWS Batch job ${result.jobId}`)
  } catch (error) {
    console.error(error)
    return error
  }

  return result
}