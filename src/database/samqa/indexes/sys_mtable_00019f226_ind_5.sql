create index samqa.sys_mtable_00019f226_ind_5 on
    samqa.sys_export_schema_01 (
        original_object_schema,
        original_object_name,
        partition_name
    );


-- sqlcl_snapshot {"hash":"7b0d36251c9453e03b60d4b6f08107dfcf2634dc","type":"INDEX","name":"SYS_MTABLE_00019F226_IND_5","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SYS_MTABLE_00019F226_IND_5</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>SYS_EXPORT_SCHEMA_01</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ORIGINAL_OBJECT_SCHEMA</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ORIGINAL_OBJECT_NAME</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>PARTITION_NAME</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}