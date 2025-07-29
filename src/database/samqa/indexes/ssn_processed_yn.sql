create index samqa.ssn_processed_yn on
    samqa.debit_card_updates (
        acc_num_processed
    );


-- sqlcl_snapshot {"hash":"449bb73dc433b637cfb520979ae5de5bcb97226e","type":"INDEX","name":"SSN_PROCESSED_YN","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SSN_PROCESSED_YN</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>DEBIT_CARD_UPDATES</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_NUM_PROCESSED</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}