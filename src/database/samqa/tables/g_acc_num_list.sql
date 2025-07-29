create global temporary table samqa.g_acc_num_list (
    acc_num varchar2(30 byte)
) on commit delete rows;


-- sqlcl_snapshot {"hash":"b07a8d375d475aca38993debbd3237b5a5bce410","type":"TABLE","name":"G_ACC_NUM_LIST","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <GLOBAL_TEMPORARY></GLOBAL_TEMPORARY>\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>G_ACC_NUM_LIST</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_NUM</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>30</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <ON_COMMIT>DELETE</ON_COMMIT>\n   </RELATIONAL_TABLE>\n</TABLE>"}