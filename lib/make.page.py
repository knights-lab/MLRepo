import csv
import dominate
from dominate.tags import *
jinja2 templating -- 
travis for automatically integrating new data into github

doc = dominate.document(title='Dominate your HTML')


f = open('bacteremia.txt')
lines = f.readlines()
f.close()

with doc.head:
    link(rel='stylesheet', href='style.css')
    script(type='text/javascript', src='script.js')

with doc:
    with div(id='header'):
        for i in lines:
            li(i.title())

    with div():
        attr(cls='body')
        p('Lorem ipsum..')

print(doc)