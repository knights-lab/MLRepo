# Available Tasks
[Download a single file](https://s3.us-east-2.amazonaws.com/knights-lab/public/MLRepo/datasets.tar.gz) containing all available tasks

{% for area_name, nested_dict in index_dict.items() %}
## {{ area_name }}
{% for task_name, task_url in nested_dict.items() %}
* [{{ task_name }}]({{ task_url }})
{% endfor %}
{% endfor %}
