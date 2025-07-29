create index samqa.sys_mtable_00019f226_ind_3 on
    samqa.sys_export_schema_01 (
        object_schema,
        object_name,
        object_type,
        partition_name,
        subpartition_name
    );


-- sqlcl_snapshot {"hash":"5aec91577e89a9502c3a27b16addd0a6d06f71f8","type":"INDEX","name":"SYS_MTABLE_00019F226_IND_3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SYS_MTABLE_00019F226_IND_3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>SYS_EXPORT_SCHEMA_01</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>OBJECT_SCHEMA</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>OBJECT_NAME</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>OBJECT_TYPE</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>PARTITION_NAME</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>SUBPARTITION_NAME</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}