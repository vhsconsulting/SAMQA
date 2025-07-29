create index samqa.deposit_register_n3 on
    samqa.deposit_register ( to_date(
        trans_date, 'MM/DD/YYYY') );


-- sqlcl_snapshot {"hash":"28864b008ad7d98fb6ebdc93a379f90dae1b2a6d","type":"INDEX","name":"DEPOSIT_REGISTER_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>DEPOSIT_REGISTER_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>DEPOSIT_REGISTER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TO_DATE(\"TRANS_DATE\",'MM/DD/YYYY')</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}