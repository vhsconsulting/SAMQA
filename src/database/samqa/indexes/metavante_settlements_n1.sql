create index samqa.metavante_settlements_n1 on
    samqa.metavante_settlements ( to_char(settlement_number)
                                  || transaction_date );


-- sqlcl_snapshot {"hash":"6ce433a6ef0f02f2c20c7270b46ce2965d42a2a1","type":"INDEX","name":"METAVANTE_SETTLEMENTS_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>METAVANTE_SETTLEMENTS_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>METAVANTE_SETTLEMENTS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TO_CHAR(\"SETTLEMENT_NUMBER\")||\"TRANSACTION_DATE\"</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}