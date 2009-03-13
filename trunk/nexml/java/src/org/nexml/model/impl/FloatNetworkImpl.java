package org.nexml.model.impl;

import org.nexml.model.FloatEdge;
import org.nexml.model.Network;
import org.nexml.model.Node;
import org.w3c.dom.Document;

class FloatNetworkImpl extends NetworkImpl<FloatEdge> implements Network<FloatEdge> {

	public FloatNetworkImpl(Document document) {
		super(document);
	}

	/**
	 * This creates an edge element. Because edge elements
	 * require source and target attributes, these need to
	 * be passed in here.
	 * @author rvosa
	 */
	@Override
	public FloatEdge createEdge(Node source, Node target) {
		FloatEdgeImpl floatEdge = new FloatEdgeImpl(getDocument()); 
		addThing(floatEdge);
		getElement().appendChild(floatEdge.getElement());
		floatEdge.setSource(source);
		floatEdge.setTarget(target);
		return floatEdge;
	}
}