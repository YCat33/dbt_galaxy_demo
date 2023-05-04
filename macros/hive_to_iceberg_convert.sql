{% macro hive_to_iceberg_convert(source_table, destination_table, file_type, table_format, object_location) %}

  {% set query %}
      SELECT column_name, data_type
      FROM   information_schema.columns
      WHERE table_name = '{{ source_table }}' 
  {% endset %}

  {% set columns = run_query(query) %}

  {% set new_columns = [] %}

  {% for column in columns %}
    {% if column['data_type'] == 'timestamp(3)' %}
        {% do log('This column has been identified as timestamp(3) ' ~ column) %}
      {% set column_def = 'cast( ' ~ column['column_name'] ~ ' as timestamp(6)) as ' ~ column['column_name'] %}
    {% else %}
      {% set column_def = column['column_name'] %}
    {% endif %}
    {% set _ = new_columns.append(column_def)%}
  {% endfor %}



  {% set string_cols = new_columns | join(',') %}



  {% if string_cols %}
    {% set ctas %}
    CREATE TABLE {{ destination_table }}
    WITH
    (format = '{{ file_type }}', type = '{{ table_format }}', location='{{ object_location }}')
    AS SELECT {{ string_cols }}
    FROM {{ source_table }};
    {% endset %}

    {% do run_query(ctas) %}
{% else %}
    {{ log("Column list is empty. Skipping CTAS query.") }}
{% endif %}


{% endmacro %}