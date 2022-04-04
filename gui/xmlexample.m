function xmlexample (instruct, xmlfilename)
% XMLEXAMPLE write a structure to xml file (an example)
%
% Usage: xmlexample(struct('a', 1, 'df', 231), 'a.xml')
%
%
% Expects
% -------
% instruct: a structure
% xmlfilename: an output file name

fi = fields(instruct);
val = struct2cell(instruct);
xDoc = com.mathworks.xml.XMLUtils.createDocument('dataexchange');
xDocRootNode = xDoc.getDocumentElement;

for q=1:numel(fi)
dataNode = xDoc.createElement('data');
nameNode = xDoc.createElement('name');
valNode = xDoc.createElement('value');
nameNode.setTextContent(fi{q});
valNode.setTextContent(num2str(val{q}));
dataNode.appendChild(nameNode);
dataNode.appendChild(valNode);
xDocRootNod.appendChild(dataNode);
end
xmlwrite(xmlfilename, xDoc);