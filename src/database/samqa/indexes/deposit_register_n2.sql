create index samqa.deposit_register_n2 on
    samqa.deposit_register (
        check_number
    );


-- sqlcl_snapshot {"hash":"d551c18561e7c0def7c7fcf82fd5c97becd9768e","type":"INDEX","name":"DEPOSIT_REGISTER_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>DEPOSIT_REGISTER_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>DEPOSIT_REGISTER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CHECK_NUMBER</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}