function ok = write_qkml(publicID,derivedOriginID,momentMagnitudeID,scalarMoment)
%,tensor,variance,varianceReduction,mrr,mtt,mpp,mrt,mrp,mtp)
 %source_model_name = 'EMME Background Seismicity [ver07] ';
 
% docNode = com.mathworks.xml.XMLUtils.createDocument('qkml');
% qkml = docNode.getDocumentElement;
% qkml.setAttribute('xmlns:gml','http://www.opengis.net/gml');
% qkml.setAttribute('xmlns', 'http://openquake.org/xmlns/nrml/0.4');
% 
% % write source model
% mt_element = docNode.createElement('momentTensor');
% qkml.appendChild(mt_element); 
%     
%     thisElement = docNode.createElement('derivedOriginID');
%     thisElement.appendChild(docNode.createTextNode('smi:org.globalcmt/origin/C200501010120A'));
%     qkml.appendChild(thisElement );
% 
%     
%     thisElement1 = docNode.createElement('scalarMoment');
%     qkml.appendChild(thisElement1);
% 
%     thisElement2 = docNode.createElement('value');
%     thisElement2.appendChild(docNode.createTextNode('5'));
%     qkml.appendChild(thisElement2);
%     
%     
% xmlFileName = 'test.xml';
% xmlwrite(xmlFileName,docNode);
% 
% 
% 
% pause

docNode = com.mathworks.xml.XMLUtils.createDocument('momentTensor');
docRootNode = docNode.getDocumentElement;

    thisElement1 = docNode.createElement('derivedOriginID');
    thisElement1.appendChild(docNode.createTextNode('smi:org.globalcmt/origin/C200501010120A'));
    docRootNode.appendChild(thisElement1);
    
thisElement2 = docNode.createElement('scalarMoment');
 docRootNode.appendChild(thisElement2); 

    thisElement3 = docNode.createElement('value');
    thisElement3.appendChild(docNode.createTextNode('5'));
    docRootNode.appendChild(thisElement3);
    

     
    tensor1=docNode.createElement('tensor');
    docRootNode.appendChild(tensor1);
     
    

 xmlFileName = 'test.xml';
 xmlwrite(xmlFileName,docNode);
% 

%%
 
docNode2 = com.mathworks.xml.XMLUtils.createDocument('tensor');
docRootNode2 = docNode2.getDocumentElement;

str2=xmlwrite(docRootNode2)

  


%%
% xmlFileName = 'test.xml';
% xmlwrite(xmlFileName,docRootNode);

