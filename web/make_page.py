#!/usr/bin/env python

import os
import csv
import collections
from jinja2 import Environment, FileSystemLoader
from flask import render_template


PATH = os.path.dirname(os.path.abspath(__file__))
TEMPLATE_ENVIRONMENT = Environment(
    autoescape=False,
    loader=FileSystemLoader(os.path.join(PATH, 'templates')),
    trim_blocks=False)

def render_template(template_filename, context):
    return TEMPLATE_ENVIRONMENT.get_template(template_filename).render(context)

# create individual pages for detailed dataset descriptions
def create_dataset_pages(fn):
    dataset_pages = {}
    with open(fn, "r") as f:
        reader = csv.reader(f, delimiter='\t')
        headers = next(reader) # read in the header
        for line in reader:
            metadata = dict(zip(headers, line)) # pair up var names with entries in each line
            dataset_pages[metadata['project_name']] = create_new_page(metadata, "base_dataset.md", "project_id")

# create individual pages for each task
def create_task_pages(fn):
    index_dict = collections.defaultdict(dict) # dict of dicts
    with open(fn, "r") as f:
        reader = csv.reader(f, delimiter='\t')
        headers = next(reader) # read in the header
        for line in reader:
            metadata = dict(zip(headers, line)) # pair up var names with entries in each line
            s = str.split(metadata["taskfn"], "/")
            metadata["taskfn_short"] = s[-1]
            index_dict[metadata['area']][metadata['task_name']] = create_new_page(metadata, "base_task.md", "task_id") # create new page, save path
    create_index_page(dict(index_dict))

# create new MD page
def create_new_page(metadata, base_md, fn_var):
    filepath = "docs/" + metadata[fn_var] + ".md"
    with open("../" + filepath, 'w') as f:
        md = render_template(base_md, metadata)
        f.write(md)
    return filepath

def create_index_page(index_dict):
    with open('../README.md', 'w') as f:
        md = render_template('base_index.md', {'index_dict': index_dict})
        f.write(md)

def main():
    #create_pages(sys.argv[1])
    create_dataset_pages("./data/datasets.txt")
    create_task_pages("./data/tasks.txt")

########################################

if __name__ == "__main__":
    main()
