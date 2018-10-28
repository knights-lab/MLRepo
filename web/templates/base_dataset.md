# {{ project_name }}
### {{ short_desc }}

| Overview | |
| -------------: |-------------|
| Description      | {{ short_desc }} |
| Study design | {{ study_design }} |
| Topic area | {{ area }}|
| Attributes | {{ attributes_values | replace(';','<br/>')}}|
| Dataset notes | {{ study_design_notes }}|
| Number of samples | {{ num_samples }}|
| Number of subjects | {{ num_subjects }}|


| Other Details |  |
| -------------: |-------------|
| 16s hypervariable region | {{ v_region }} |
| Targeted amplicon size | {{ target_size }} |
| Sequencing technology | {{ sequencing_technology }} |
| Fraction of sequences mapped to database | {{ percent_db_hits }} |
| Processed sequences | [{{processed_fasta | replace('https://s3.us-east-2.amazonaws.com/knights-lab/public/MLRepo/fasta/','')}}]({{ processed_fasta}}) |
| Raw metadata file | [mapping-orig.txt](.{{original_mapping_file}}) |
| Raw sequence source | [{{ raw_data_source }}]({{ raw_data_source }}) |
| Literature source | [{{ literature_source }}]({{ literature_source }}) |

[back to task index](../README.md)