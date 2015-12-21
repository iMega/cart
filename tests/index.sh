#!/usr/bin/env bash

URL=$1

assertTrue() {
    if [ "$1" != "$2" ]; then
        echo "Fail:" $3
        exit 1;
    fi
    echo $3
}

testFailGetItems() {
    RESPONSE=$(curl --write-out %{http_code} --silent --output /dev/null http://$URL/ce9d0109-4b5b-4b48-b8d6-1714b217dc00)

    assertTrue 404 $RESPONSE testFailGetItems
}

testPutItem() {
    RESPONSE=$(curl --write-out %{http_code} --silent --output /dev/null -X PUT -d '{
        "cart_uuid": "a727cbf0-d165-4703-bf57-3a8af0b83cbd",
        "product_id": "6126f97c-29fe-4be4-94df-4e3677d7b129",
        "title": "iPhone 6S 16Gb",
        "price": 749,
        "preview": "http://example.com/url_to_image_preview.png",
        "quantity": 1,
        "url": "http://example.com/url_to_page_detail_product"
    }' http://$URL)

    assertTrue 201 $RESPONSE testPutItem
}

testGetItems() {
    RESPONSE=$(curl --write-out %{http_code} --silent --output /dev/null http://$URL/a727cbf0-d165-4703-bf57-3a8af0b83cbd)

    assertTrue 200 $RESPONSE testGetItems
}

testGetItem() {
    RESPONSE=$(curl --write-out %{http_code} --silent --output /dev/null http://$URL/a727cbf0-d165-4703-bf57-3a8af0b83cbd/6126f97c-29fe-4be4-94df-4e3677d7b129)

    assertTrue 200 $RESPONSE testGetItem
}

testFailPutItem() {
    RESPONSE=$(curl --write-out %{http_code} --silent --output /dev/null -X PUT -d '{
        "cart_uuid": "a727cbf0-d165-4703-bf57-3a8af0b83cbd",
        "product_id": "6126f97c-29fe-4be4-94df-4e3677d7b129",
        "title": "iPhone 6S 16Gb",
        "price": 749,
        "preview": "http://example.com/url_to_image_preview.png",
        "quantity": 1,
        "url": "http://example.com/url_to_page_detail_product"
    }' http://$URL)

    assertTrue 409 $RESPONSE testFailPutItem
}

testPostItem() {
    RESPONSE=$(curl --write-out %{http_code} --silent --output /dev/null -X POST -d '{
        "cart_uuid": "a727cbf0-d165-4703-bf57-3a8af0b83cbd",
        "product_id": "6126f97c-29fe-4be4-94df-4e3677d7b129",
        "title": "iPhone 6S 16Gb",
        "price": 749,
        "preview": "http://example.com/url_to_image_preview.png",
        "quantity": 2,
        "url": "http://example.com/url_to_page_detail_product"
    }' http://$URL)

    assertTrue 200 $RESPONSE testPostItem
}

testFailPostItem() {
    RESPONSE=$(curl --write-out %{http_code} --silent --output /dev/null -X POST -d '{
        "cart_uuid": "a727cbf0-d165-4703-bf57-3a8af0b83cbd",
        "title": "iPhone 6S 16Gb",
        "price": 749,
        "preview": "http://example.com/url_to_image_preview.png",
        "quantity": 2,
        "url": "http://example.com/url_to_page_detail_product"
    }' http://$URL)

    assertTrue 400 $RESPONSE testFailPostItem
}

testFailPostItem2() {
    RESPONSE=$(curl --write-out %{http_code} --silent --output /dev/null -X POST -d '{
        "cart_uuid": "a727cbf0-d165-4703-bf57-3a8af0b83cbd",
        "product_id": "7776f97c-2222-4be4-94df-4e3677d7b129",
        "title": "iPhone 6S 16Gb",
        "price": 749,
        "preview": "http://example.com/url_to_image_preview.png",
        "quantity": 2,
        "url": "http://example.com/url_to_page_detail_product"
    }' http://$URL)

    assertTrue 404 $RESPONSE testFailPostItem2
}

testDeleteItem() {
    RESPONSE=$(curl --write-out %{http_code} --silent --output /dev/null -X DELETE http://$URL/a727cbf0-d165-4703-bf57-3a8af0b83cbd/6126f97c-29fe-4be4-94df-4e3677d7b129)

    assertTrue 200 $RESPONSE testDeleteItem
}

testFailDeleteItem() {
    RESPONSE=$(curl --write-out %{http_code} --silent --output /dev/null -X DELETE http://$URL/a727cbf0-d165-4703-bf57-3a8af0b83cbd/6126f97c-2222-4be4-94df-4e3677d7b129)

    assertTrue 404 $RESPONSE testFailDeleteItem
}

testFailGetItems

testPutItem

testGetItems
testGetItem

testFailPutItem

testPostItem
testFailPostItem
testFailPostItem2

testDeleteItem
testFailDeleteItem

echo "Passed"

exit 0
