create index samqa.bill_format_staging_n4 on
    samqa.bill_format_staging (
        emp_acc_id,
        emp_acc_num
    );


-- sqlcl_snapshot {"hash":"e3336d27b1fae629ff865aa9511fa078e4d9143d","type":"INDEX","name":"BILL_FORMAT_STAGING_N4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BILL_FORMAT_STAGING_N4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BILL_FORMAT_STAGING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>EMP_ACC_ID</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>EMP_ACC_NUM</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}