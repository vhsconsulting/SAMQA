create index samqa.activity_statement_n5 on
    samqa.activity_statement (
        acc_num,
        begin_date,
        end_date
    );


-- sqlcl_snapshot {"hash":"b34742490a6f2ef6958dc6a23ee51d4809124782","type":"INDEX","name":"ACTIVITY_STATEMENT_N5","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ACTIVITY_STATEMENT_N5</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ACTIVITY_STATEMENT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_NUM</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>BEGIN_DATE</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>END_DATE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}