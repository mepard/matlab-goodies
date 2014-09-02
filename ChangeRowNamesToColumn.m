function t = ChangeRowNamesToColumn (t, columnName)
	if istable(t)
		t.(columnName) = t.Properties.RowNames;
		t.Properties.RowNames = {};
	end
end
