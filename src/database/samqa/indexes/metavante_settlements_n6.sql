create index samqa.metavante_settlements_n6 on
    samqa.metavante_settlements ( trunc(to_date(
        settlement_date, 'YYYYMMDD')) );


-- sqlcl_snapshot {"hash":"5e665cf06215cfe8a25c4e0b4fe304b00fb6a300","type":"INDEX","name":"METAVANTE_SETTLEMENTS_N6","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>METAVANTE_SETTLEMENTS_N6</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>METAVANTE_SETTLEMENTS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TRUNC(TO_DATE(\"SETTLEMENT_DATE\",'YYYYMMDD'))</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}