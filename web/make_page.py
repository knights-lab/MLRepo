#!/usr/bin/env python

import sys
import os
import csv
from jinja2 import Environment, FileSystemLoader
import markdown
from flask import Flask
from flask import render_template


PATH = os.path.dirname(os.path.abspath(__file__))
TEMPLATE_ENVIRONMENT = Environment(
    autoescape=False,
    loader=FileSystemLoader(os.path.join(PATH, 'templates')),
    trim_blocks=False)


def render_template(template_filename, context):
    return TEMPLATE_ENVIRONMENT.get_template(template_filename).render(context)


varnames = ['project_name', 'project_id', 'v_region', 'target_size', 'raw_data_source', 'num_samples',
    'num_subjects', 'study_design_notes', 'area', 'attribute_data_type', 'attributes_values', 'short_desc', 'long_desc',
    'literature_source', 'sequencing_technology', 'study_design', 'num_attributes', 'tasks', 'percent_db_hits']

md_template = """
some code here
"""


def create_pages(fn):
    with open(fn, "r") as f:
        next(f)  # skip the header
        reader = csv.reader(f, delimiter='\t')
        for line in reader:
            metadata = dict(zip(varnames, line))
            create_new_page(metadata)


def create_new_page(metadata):
    fname = "pages/" + metadata['project_id'] + ".md"

    metadata['attributes'] = metadata['attributes_values'].split(";")

    with open(fname, 'w') as f:
        md = render_template('base.md', metadata)
        f.write(md)

def main():
    #create_pages(sys.argv[1])
    create_pages("./data/dataset_metadata.tsv")

########################################

if __name__ == "__main__":
    main()
