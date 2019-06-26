view: storage_usage_core {
  sql_table_name:
  {% if database_name._in_query or database_id._in_query %}
  SNOWFLAKE_GENERATED.ACCOUNT_USAGE.DATABASE_STORAGE_USAGE_HISTORY
  {% else %}
  SNOWFLAKE_GENERATED.ACCOUNT_USAGE.STORAGE_USAGE
  {% endif %};;

  dimension: database_id {
    type: number
    sql: ${TABLE}.DATABASE_ID ;;
  }

  dimension_group: deleted {
    #if this is exposed - will need to include it table selection logic
    type: time
    hidden: yes
    sql: ${TABLE}.DELETED ;;
  }

  dimension: database_name {
    type: string
    sql: ${TABLE}.DATABASE_NAME ;;
  }

  dimension_group: usage {
    type: time
    datatype: date
    timeframes: [date,week,week_of_year,day_of_week,day_of_month,month_num,month,quarter,year]
    convert_tz: no
    sql: ${TABLE}.USAGE_DATE ;;
    alias: [read]
  }

  dimension: storage_bytes {
    type: number
    sql: {% if database_name._in_query or database_id._in_query %}
    ${TABLE}.AVERAGE_DATABASE_BYTES
    {% else %}
    ${TABLE}.STORAGE_BYTES
    {% endif %}
     ;;
  }
  dimension: failsafe_bytes {
    type: number
    sql: {% if database_name._in_query or database_id._in_query %}
    ${TABLE}.AVERAGE_FAILSAFE_BYTES
    {% else %}
    ${TABLE}.FAILSAFE_BYTES
     {% endif %};;
  }

  dimension: storage_tb {
    type: number
    sql: ${storage_bytes} / power(1024,4) ;;
  }


  dimension: failsafe_tb {
    type: number
    sql: ${failsafe_bytes} / power(1024,4) ;;
  }

  dimension: total_tb {
    sql: ${storage_tb} + ${failsafe_tb};;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  measure: billable_tb {
    type: average
    sql: ${total_tb};;
  }

  measure: current_four_weeks_billable_tb {
    type: average
    sql:  ${total_tb};;
    filters: {field: usage_date value: "last 4 weeks"}
    value_format_name: decimal_4
  }

  measure: prior_four_weeks_billable_tb {
    type: average
    sql:  ${total_tb};;
    filters: {field: usage_date value: "8 weeks ago for 4 weeks"}
    value_format_name: decimal_4
  }
}