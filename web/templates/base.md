# {{ project_name }}

# {{ short_desc }}


| Details        |             |
| -------------: |-------------|
| Description      | {{ short_desc }} |
| Number of samples     | {{ num_samples }}      |
| Number of subjects | {{ num_subjects }}      |
| Study design | {{ study_design }} |
| Field | {{ area }}|
| Attributes | {% set counter = 0 -%} {% for a in attributes -%} * {{ a }} {% set counter = counter + 1 -%} {% endfor -%}|
| Suggestions | {{ study_design_notes }}

### Additional details

| 16s hypervariable region | {{ v_region }} |
| Targeted amplicon size | {{ target_size }} |
| Sequencing Technology | {{ sequencing_technology }} |
| Fraction of sequences mapped to database | {{ percent_db_hits }} |
| Raw Sequences | {{ raw_data_source }} |
| Literature Source | {{ literature_source }} |
