from __future__ import absolute_import

# import pandas as pd
import json

import argparse
import logging
import re

# import apache_beam as beam
# from apache_beam.io import (ReadFromText, WriteToText)
# from apache_beam.options.pipeline_options import (PipelineOptions, SetupOptions, StandardOptions)

# class ProcessBeamFn(beam.DoFn):
#     def process(self, element):
#         # import ipdb;ipdb.set_trace()
#         return [len(element)]

def main(argv=None):
    parser = argparse.ArgumentParser()
    # parser.add_argument('--input',
    #                     dest='input',
    #                     default='gs://dataflow-samples/shakespeare/kinglear.txt',
    #                     help='Input file to process.')
    # parser.add_argument('--output',
    #                     dest='output',
    #                     # CHANGE 1/5: The Google Cloud Storage path is required
    #                     # for outputting the results.
    #                     default='gs://YOUR_OUTPUT_BUCKET/AND_OUTPUT_PREFIX',
    #                     help='Output file to write results to.')
    # known_args, pipeline_args = parser.parse_known_args(argv)
    # pipeline_args.extend([
    #     '--runner=DirectRunner',
    #     '--project=csv',
    #     '--staging_location=/home/cqshinn/tmp',
    #     '--temp_location=/tmp',
    #     '--job_name=parse',
    # ])
    # pipeline_options = PipelineOptions(pipeline_args)
    # pipeline_options.view_as(SetupOptions).save_main_session = True
    # with beam.Pipeline(options=pipeline_options) as p:
    #     line = p | 'ReadMyFile' >> beam.io.ReadFromText('../logs/devices.log') \
    #              | beam.ParDo(ProcessBeamFn()) \
    #              | beam.io.WriteToText('../samples/files/rdevices.json')
    with open('./devices.log') as f:
        data = []
        for line in f.readlines():
            try:
                parse = json.loads(line)
                data.append({
                    "uuid": parse["uuid"],
                    "token": parse["token"],
                })
            except:
                pass
        with open('../samples/files/devices.json', 'w+') as w:
            w.write(json.dumps({
                "devices": data
            }, indent=4 ))

main()