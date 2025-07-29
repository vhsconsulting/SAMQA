create index samqa.employer_payment_detail_n9 on
    samqa.employer_payment_detail (
        change_num,
        transaction_source
    );


-- sqlcl_snapshot {"hash":"472f3662bd5a3db89191ce275954ff504cf93aeb","type":"INDEX","name":"EMPLOYER_PAYMENT_DETAIL_N9","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EMPLOYER_PAYMENT_DETAIL_N9</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EMPLOYER_PAYMENT_DETAIL</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CHANGE_NUM</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>TRANSACTION_SOURCE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}