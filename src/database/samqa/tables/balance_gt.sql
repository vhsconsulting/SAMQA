create global temporary table samqa.balance_gt (
    balance  number,
    acc_id   number(9, 0) not null enable,
    interest number
) on commit preserve rows;


-- sqlcl_snapshot {"hash":"f9753aa96b8b8a2bd172bf473b8ab3d21ad882f2","type":"TABLE","name":"BALANCE_GT","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <GLOBAL_TEMPORARY></GLOBAL_TEMPORARY>\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BALANCE_GT</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BALANCE</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ACC_ID</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>9</PRECISION>\n            <SCALE>0</SCALE>\n            <NOT_NULL></NOT_NULL>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>INTEREST</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <ON_COMMIT>PRESERVE</ON_COMMIT>\n   </RELATIONAL_TABLE>\n</TABLE>"}