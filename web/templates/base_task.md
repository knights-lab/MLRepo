# Task: {{task_name}}
### {{ description }}

| | |
| ------------------------: |-----------------------------------------------------------|
| **Project**           | [{{ project_name }}]( ../docs/{{project_id}}.html )       |
| **Topic area**                | {{ area }}                                                |
| **Sample type**               | {{ sample_type }}                                         |
| **Number of samples**         | {{ num_samples }}                                         |
| **Response type**             | {{ data_type }}                                           |
| **Additional task details**   | {{ study_design_notes }}                                  |
| **Multiple samples per subject?** | {{ control_vars | replace('N','No') | replace('Y','Yes') }} |
| **Task mapping file**         | [{{taskfn_short}}](.{{taskfn}})                                 |
| **OTU file** *gg97*           | [otutable.txt](.{{otufn_gg}})                             |
| **Taxa file** *gg97*          | [taxatable.txt](.{{taxafn_gg}})                          |
| **OTU file** *RefSeq*         | [otutable.txt](.{{otufn_refseq}})                    |
| **Taxa file** *RefSeq*        | [taxatable.txt](.{{taxafn_refseq}})                  |

[back to task index](../README.md)