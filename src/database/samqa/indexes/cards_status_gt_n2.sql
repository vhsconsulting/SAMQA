create index samqa.cards_status_gt_n2 on
    samqa.cards_status_gt (
        card_number
    );


-- sqlcl_snapshot {"hash":"1c788fbbc78e5a1257be55c9f216b70235c583f9","type":"INDEX","name":"CARDS_STATUS_GT_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CARDS_STATUS_GT_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CARDS_STATUS_GT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CARD_NUMBER</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <INDEX_ATTRIBUTES></INDEX_ATTRIBUTES>\n   </TABLE_INDEX>\n</INDEX>"}