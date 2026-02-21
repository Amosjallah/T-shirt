$files = Get-ChildItem -Path "." -Recurse -Include "*.ts","*.tsx","*.json","*.md","*.env" |
    Where-Object { $_.FullName -notmatch "node_modules|\.next|package-lock|rebrand\.ps1" }

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    $original = $content

    # Brand name replacements
    $content = $content -replace 'MultiMey Supplies', 'BEADEDLUX'
    $content = $content -replace 'MultiMey', 'BEADEDLUX'
    $content = $content -replace 'multimeysupplies\.com', 'beadedlux.com'
    $content = $content -replace 'classy-debbie-collection', 'beadedlux'
    $content = $content -replace 'Toucheeglow', 'BEADEDLUX'
    $content = $content -replace 'toucheeglow\.com', 'beadedlux.com'
    $content = $content -replace 'noreply@beadedlux\.com', 'noreply@beadedlux.com'

    # Tagline / description replacements
    $content = $content -replace 'Quality Products & Supplies', 'Quality Designer Ladies Bags'
    $content = $content -replace 'Quality Products and Supplies', 'Quality Designer Ladies Bags'
    $content = $content -replace 'Shop dresses, electronics, bags, shoes & more at BEADEDLUX', 'Discover luxury designer ladies bags at BEADEDLUX. Premium handbags, clutches & accessories.'
    $content = $content -replace 'Shop dresses, electronics, bags, shoes and more at BEADEDLUX', 'Discover luxury designer ladies bags at BEADEDLUX. Premium handbags, clutches and accessories.'
    $content = $content -replace 'Shop dresses, electronics, bags, shoes & more', 'Discover luxury designer ladies bags, handbags & accessories'
    $content = $content -replace 'Shop dresses, electronics, bags, shoes and more', 'Discover luxury designer ladies bags, handbags and accessories'
    $content = $content -replace 'dresses, electronics, bags, shoes and more', 'quality designer ladies bags, handbags and accessories'
    $content = $content -replace 'dresses, electronics, bags, shoes & more', 'quality designer ladies bags, handbags & accessories'
    $content = $content -replace 'quality products, Ghana shopping', 'designer bags, luxury handbags, Ghana'
    $content = $content -replace 'Quality products', 'Quality designer bags'

    # SKU prefix
    $content = $content -replace "const prefix = 'MMS'", "const prefix = 'BLX'"
    $content = $content -replace "prefix = 'MMS'", "prefix = 'BLX'"

    # SMS sender id
    $content = $content -replace "senderid: 'BEADEDLUX'", "senderid: 'BEADEDLUX'"

    # Accra address still fine, just brand
    if ($content -ne $original) {
        [System.IO.File]::WriteAllText($file.FullName, $content)
        Write-Host "Updated: $($file.FullName)"
    }
}

Write-Host "Done!"
